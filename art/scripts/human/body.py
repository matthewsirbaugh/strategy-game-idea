"""The CC0 MakeHuman body with its eyes, brows and lashes, and their materials."""
import json
import bpy
from .shading import Graph, VENDOR, srgb

MH = VENDOR / 'makehuman'
# The Installer's look; a character spec overrides any of these.
LOOK = dict(skin='skin_indian_female_enhanced.png', hue=.505, saturation=.92, value=.82, tint='#B98C6A',
            tint_amount=.3, lips='#A85E55', lips_amount=.6, eyes='eye_brown.png', brows='eyebrow008.png',
            brow_color='#1A120E', lashes='eyelashes01.png', lash_color='#0E0B0A')
PARTS = ('body', 'skeleton', 'eyes', 'eyebrows', 'eyelashes')


def load_base(collection, path, prefix=''):
    """Link a base .blend's body, skeleton and proxies into collection; returns them by part name."""
    with bpy.data.libraries.load(str(path), link=False) as (src, dst):
        dst.objects = [n for n in src.objects if n in PARTS]
    parts = {}
    for o in dst.objects:
        collection.objects.link(o)
        name = o.name.split('.')[0]
        if prefix:
            o.name = prefix + name
        parts[name] = o
    return parts


def pore_bump(g, strength=.12):
    coord = g.node('ShaderNodeTexCoord').outputs['Object']
    fine = g.node('ShaderNodeTexNoise', Vector=coord, Scale=2200.0, Detail=4.0, Roughness=.6)
    pores = g.node('ShaderNodeTexVoronoi', Vector=coord, Scale=900.0)
    pores.feature = 'F1'
    height = g.math('MULTIPLY', pores.outputs['Distance'], .6)
    height = g.math('ADD', height, g.math('MULTIPLY', fine.outputs['Fac'], .4))
    return g.node('ShaderNodeBump', Strength=strength, Distance=.0004, Height=height).outputs['Normal']


def skin_material(look):
    g = Graph('skin')
    tex = g.image(MH / look['skin'])
    hsv = g.node('ShaderNodeHueSaturation', Hue=look['hue'], Saturation=look['saturation'], Value=look['value'],
                 Color=tex.outputs['Color'])
    tone = g.mix(hsv.outputs['Color'], srgb(look['tint']), look['tint_amount'], 'MULTIPLY')
    # MakeHuman skins paint dark lips; the lip mask lifts them toward the look's lip colour
    lips = g.node('ShaderNodeVertexColor', layer_name='lips')
    lip_col = g.mix(hsv.outputs['Color'], srgb(look['lips']), look['lips_amount'], 'MIX')
    tone = g.mix(tone, lip_col, g.node('ShaderNodeSeparateColor', Color=lips.outputs['Color']).outputs['Red'])
    rough_noise = g.node('ShaderNodeTexNoise', Scale=60.0, Detail=3.0)
    rough = g.math('ADD', .5, g.math('MULTIPLY', g.math('SUBTRACT', rough_noise.outputs['Fac'], .5), .12))
    g.set(**{'Base Color': tone, 'Roughness': rough, 'Subsurface Weight': .18,
             'Subsurface Radius': (1.0, .38, .2), 'Subsurface Scale': .006,
             'Specular IOR Level': .38, 'Normal': pore_bump(g)})
    return g.mat


def eye_material(look):
    g = Graph('eyes')
    tex = g.image(MH / look['eyes'])
    iris = g.node('ShaderNodeHueSaturation', Hue=.51, Saturation=.75, Value=.8, Color=tex.outputs['Color'])
    g.set(**{'Base Color': iris.outputs['Color'], 'Roughness': .35, 'Specular IOR Level': .3})
    return g.mat


def cornea_material():
    g = Graph('cornea')
    g.set(**{'Base Color': (1, 1, 1, 1), 'Roughness': .02, 'Transmission Weight': 1.0, 'IOR': 1.376,
             'Specular IOR Level': .8})
    return g.mat


def split_cornea(eyes):
    """The MakeHuman eye mesh maps its cornea shell to the bottom-right corner of the texture."""
    eyes.data.materials.append(cornea_material())
    uv = eyes.data.uv_layers.active.data
    for p in eyes.data.polygons:
        u = sum(uv[i].uv.x for i in p.loop_indices) / p.loop_total
        v = sum(uv[i].uv.y for i in p.loop_indices) / p.loop_total
        if u > .85 and v < .15:
            p.material_index = 1


def hair_card_material(name, texture, color, rough=.45):
    g = Graph(name)
    tex = g.image(MH / texture)
    g.set(**{'Base Color': g.mix(tex.outputs['Color'], srgb(color), .85, 'MULTIPLY'),
             'Alpha': tex.outputs['Alpha'], 'Roughness': rough, 'Specular IOR Level': .35})
    g.mat.surface_render_method = 'DITHERED'
    return g.mat


def lip_mask(body):
    mouth = json.loads(body['anchors'])['joint-mouth']
    me = body.data
    attr = me.color_attributes.get('lips') or me.color_attributes.new('lips', 'FLOAT_COLOR', 'POINT')
    for v in me.vertices:
        dx = abs(v.co.x) / .026
        dz = (v.co.z - (mouth[2] - .001)) / .011
        front = v.co.y < mouth[1] + .004
        w = max(0.0, 1 - (dx * dx + dz * dz)) if front else 0.0
        attr.data[v.index].color = (min(1, w * 1.6), 0, 0, 1)


def dress_body(parts, look):
    lip_mask(parts['body'])
    for key, mat in (('body', skin_material(look)), ('eyes', eye_material(look)),
                     ('eyebrows', hair_card_material('eyebrows', look['brows'], look['brow_color'])),
                     ('eyelashes', hair_card_material('eyelashes', look['lashes'], look['lash_color'], .5))):
        obj = parts[key]
        obj.data.materials.clear()
        obj.data.materials.append(mat)
        for p in obj.data.polygons:
            p.use_smooth = True
    split_cornea(parts['eyes'])
