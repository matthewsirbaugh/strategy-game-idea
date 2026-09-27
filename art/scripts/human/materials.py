"""The Installer's material library. Procedural layers (AO grime, edge wear, fading) are for Cycles;
the export bakes them into texture atlases."""
import bpy
from .shading import Graph, VENDOR, srgb

TEX = VENDOR / 'textures'


def tex_set(g, name, scale, rot=0.0, vector=None):
    """Box-projected CC0 texture set in object space. Returns (color, normal, rough) sockets or None."""
    folder = TEX / name
    if vector is None:
        coord = g.node('ShaderNodeTexCoord').outputs['Object']
        mapping = g.node('ShaderNodeMapping', Vector=coord, Scale=(scale, scale, scale), Rotation=(0, 0, rot))
        vector = mapping.outputs['Vector']
    files = {p.name: p for p in folder.iterdir()}

    def pick(*keys):
        for f, p in files.items():
            if any(k in f for k in keys):
                return p
        return None
    out = {}
    for key, cs, keys in (('color', 'sRGB', ('_diff_', '_Color')), ('normal', 'Non-Color', ('_nor_', 'NormalGL')),
                          ('rough', 'Non-Color', ('_rough_', 'Roughness'))):
        path = pick(*keys)
        if path:
            n = g.image(path, cs, vector)
            n.projection = 'BOX'
            n.projection_blend = .25
            out[key] = n
    return out


def normal_from(g, tset, strength, extra_bump=None):
    nm = g.node('ShaderNodeNormalMap', Strength=strength, Color=tset['normal'].outputs['Color'])
    if extra_bump is None:
        return nm.outputs['Normal']
    b = g.node('ShaderNodeBump', Strength=extra_bump[1], Distance=extra_bump[2], Height=extra_bump[0],
               Normal=nm.outputs['Normal'])
    return b.outputs['Normal']


def wear_layers(g, color, dark, light, grime=.5, edge=.4, fade_scale=6.0):
    """Mottled fading, grime in crevices (AO) and wear on raised folds and edges (pointiness)."""
    coord = g.node('ShaderNodeTexCoord').outputs['Object']
    mottle = g.node('ShaderNodeTexNoise', Vector=coord, Scale=fade_scale, Detail=4.0, Roughness=.6)
    fine = g.node('ShaderNodeTexNoise', Vector=coord, Scale=fade_scale * 12, Detail=3.0)
    c = g.mix(color, light, g.math('MULTIPLY', g.math('SUBTRACT', mottle.outputs['Fac'], .45), 1.4, clamp=True))
    c = g.mix(c, dark, g.math('MULTIPLY', g.math('SUBTRACT', fine.outputs['Fac'], .5), .6, clamp=True))
    ao = g.node('ShaderNodeAmbientOcclusion', Distance=.03, Color=(1, 1, 1, 1))
    ao.samples = 8
    cavity = g.math('POWER', g.math('SUBTRACT', 1.0, ao.outputs['AO']), 1.0)
    c = g.mix(c, dark, g.math('MULTIPLY', cavity, grime, clamp=True))
    geo = g.node('ShaderNodeNewGeometry')
    ridge = g.ramp(geo.outputs['Pointiness'], [(.53, (0, 0, 0, 1)), (.62, (1, 1, 1, 1))])
    ridge = g.math('MULTIPLY', g.node('ShaderNodeSeparateColor', Color=ridge).outputs['Red'], edge)
    ridge = g.math('MULTIPLY', ridge, g.math('ADD', .4, mottle.outputs['Fac']), clamp=True)
    return g.mix(c, light, ridge), cavity


def fabric(name, base, dark, light, tex, scale, normal=.8, rough=.85, sheen=.25, grime=.5, edge=.35,
           fade_scale=6.0, sheen_tint=None):
    g = Graph(name)
    t = tex_set(g, tex, scale)
    col, cavity = wear_layers(g, srgb(base), srgb(dark), srgb(light), grime, edge, fade_scale)
    if 'color' in t:
        weave = g.node('ShaderNodeRGBToBW', Color=t['color'].outputs['Color']).outputs['Val']
        weave = g.math('ADD', g.math('MULTIPLY', g.math('SUBTRACT', weave, .5), .9), 1.0)
        col = g.mix(col, g.node('ShaderNodeCombineColor', Red=weave, Green=weave, Blue=weave).outputs['Color'],
                    1.0, 'MULTIPLY')
    r = rough
    if 'rough' in t:
        r = g.math('ADD', g.math('MULTIPLY', t['rough'].outputs['Color'], .3), rough - .15)
    g.set(**{'Base Color': col, 'Roughness': r, 'Sheen Weight': sheen,
             'Sheen Tint': srgb(sheen_tint or light), 'Normal': normal_from(g, t, normal)})
    return g.mat


def leather(name='leather', base='#6A4127', dark='#2E1A0F', light='#A27150', tex='fabric_leather_02', scale=8.0):
    g = Graph(name)
    t = tex_set(g, tex, scale)
    col, cavity = wear_layers(g, srgb(base), srgb(dark), srgb(light), .55, .7, 8.0)
    if 'color' in t:
        grain = g.node('ShaderNodeRGBToBW', Color=t['color'].outputs['Color']).outputs['Val']
        g_c = g.node('ShaderNodeCombineColor', Red=grain, Green=grain, Blue=grain).outputs['Color']
        col = g.mix(col, g.mix((.55, .55, .55, 1), g_c, 1.0, 'MIX'), .6, 'OVERLAY')
    g.set(**{'Base Color': col, 'Roughness': g.math('ADD', .42, g.math('MULTIPLY', cavity, .3)),
             'Normal': normal_from(g, t, .8)})
    return g.mat


def webbing(name, base, dark, light, scale=30.0):
    g = Graph(name)
    t = tex_set(g, 'fabric_pattern_07', scale)
    col, _ = wear_layers(g, srgb(base), srgb(dark), srgb(light), .5, .45, 10.0)
    g.set(**{'Base Color': col, 'Roughness': .82, 'Sheen Weight': .2, 'Normal': normal_from(g, t, 1.2)})
    return g.mat


def metal(name, base, rough=.32, worn='#D8DADC', dirt='#3A3530'):
    g = Graph(name)
    col, cavity = wear_layers(g, srgb(base), srgb(dirt), srgb(worn), .7, .8, 20.0)
    scratches = g.node('ShaderNodeTexNoise', Scale=300.0, Detail=2.0)
    g.set(**{'Base Color': col, 'Metallic': 1.0,
             'Roughness': g.math('ADD', rough, g.math('MULTIPLY', cavity, .35)),
             'Normal': g.node('ShaderNodeBump', Strength=.05, Height=scratches.outputs['Fac']).outputs['Normal']})
    return g.mat


def plastic(name, base, rough=.45, dark=None, light=None, grime=.5, edge=.3):
    g = Graph(name)
    col, cavity = wear_layers(g, srgb(base), srgb(dark or '#3A3632'), srgb(light or base), grime, edge, 12.0)
    g.set(**{'Base Color': col, 'Roughness': g.math('ADD', rough, g.math('MULTIPLY', cavity, .25))})
    return g.mat


def rubber():
    g = Graph('rubber')
    t = tex_set(g, 'Rubber004', 12.0)
    col, _ = wear_layers(g, srgb('#222223'), srgb('#0E0E0E'), srgb('#5A554E'), .4, .6, 10.0)
    g.set(**{'Base Color': col, 'Roughness': .88, 'Normal': normal_from(g, t, .6)})
    return g.mat


def suede(name='suede', base='#8C7555', dark='#4A3A28', light='#B59E7A'):
    g = Graph(name)
    t = tex_set(g, 'Leather039', 14.0)
    col, _ = wear_layers(g, srgb(base), srgb(dark), srgb(light), .6, .35, 9.0)
    g.set(**{'Base Color': col, 'Roughness': .92, 'Sheen Weight': .5, 'Sheen Tint': srgb(light),
             'Normal': normal_from(g, t, .9)})
    return g.mat


def mesh_fabric(name='mesh_fabric', base='#2E3033'):
    return fabric(name, base, '#141516', '#55585B', 'Fabric030', 18.0, normal=1.2, rough=.85, sheen=.2, grime=.5)


def neoprene(name='glove_fabric', base='#252628'):
    return fabric(name, base, '#101011', '#4A4B4D', 'scuba_suede', 20.0, normal=.8, rough=.7, sheen=.2, grime=.4)


def glass():
    g = Graph('glass')
    g.set(**{'Base Color': (.93, .97, 1, 1), 'Roughness': .04, 'Transmission Weight': 1.0, 'IOR': 1.49,
             'Thin Wall': True, 'Alpha': 1.0})
    return g.mat


def emissive(name, color, strength=6.0):
    g = Graph(name)
    g.set(**{'Base Color': srgb(color), 'Emission Color': srgb(color), 'Emission Strength': strength,
             'Roughness': .15, 'Coat Weight': 1.0, 'Coat Roughness': .02})
    return g.mat


def hair():
    g = Graph('hair')
    tint = g.node('ShaderNodeVertexColor', layer_name='hair_tint')
    uvn = g.node('ShaderNodeUVMap', uv_map='UVMap')
    sep = g.node('ShaderNodeSeparateXYZ', Vector=uvn.outputs['UV'])
    comb = g.node('ShaderNodeCombineXYZ', X=g.math('MULTIPLY', sep.outputs['X'], 60.0),
                  Y=g.math('MULTIPLY', sep.outputs['Y'], 3.0))
    strands = g.node('ShaderNodeTexNoise', Vector=comb.outputs['Vector'], Scale=1.0, Detail=6.0, Roughness=.7)
    bump = g.node('ShaderNodeBump', Strength=.45, Distance=.0008, Height=strands.outputs['Fac'])
    col = g.mix(srgb('#26180F'), tint.outputs['Color'], 1.0, 'MULTIPLY')
    col = g.mix(col, g.mix(srgb('#140C08'), srgb('#4A2E1C'), strands.outputs['Fac'], 'MIX'), .35, 'MULTIPLY')
    g.set(**{'Base Color': col, 'Roughness': .5, 'Sheen Weight': .5, 'Sheen Roughness': .4,
             'Sheen Tint': srgb('#8A6A50'), 'Specular IOR Level': .35, 'Anisotropic': .5,
             'Anisotropic Rotation': .25, 'Normal': bump.outputs['Normal']})
    return g.mat


def hair_cap():
    """The swept-back hair under the curls: dark, with fine strands and soft curl clusters."""
    g = Graph('hair_cap')
    coord = g.node('ShaderNodeTexCoord').outputs['Object']
    curls = g.node('ShaderNodeTexVoronoi', Vector=coord, Scale=320.0, Randomness=1.0)
    stretch = g.node('ShaderNodeMapping', Vector=coord, Scale=(900.0, 900.0, 120.0))
    strands = g.node('ShaderNodeTexNoise', Vector=stretch.outputs['Vector'], Scale=1.0, Detail=5.0)
    h = g.math('ADD', g.math('MULTIPLY', curls.outputs['Distance'], .5), g.math('MULTIPLY', strands.outputs['Fac'], .5))
    bump = g.node('ShaderNodeBump', Strength=.35, Distance=.0015, Height=h)
    col = g.mix(srgb('#160E0A'), srgb('#3A2517'), g.math('MULTIPLY', strands.outputs['Fac'], 1.2, clamp=True))
    g.set(**{'Base Color': col, 'Roughness': .55, 'Sheen Weight': .5, 'Sheen Tint': srgb('#7A5A40'),
             'Normal': bump.outputs['Normal']})
    return g.mat


def solar_cells(cols=5, rows=6):
    """Monocrystalline cells with white bus-bar lines, drawn from the face's 0..1 UVs."""
    g = Graph('solar_cells')
    uvn = g.node('ShaderNodeUVMap', uv_map='UVMap')
    sep = g.node('ShaderNodeSeparateXYZ', Vector=uvn.outputs['UV'])
    lines = []
    for axis, count in (('X', cols), ('Y', rows)):
        f = g.math('FRACT', g.math('MULTIPLY', sep.outputs[axis], count))
        edge = g.math('MINIMUM', f, g.math('SUBTRACT', 1.0, f))
        lines.append(g.math('LESS_THAN', edge, .025))
    fingers = g.math('LESS_THAN', g.math('FRACT', g.math('MULTIPLY', sep.outputs['Y'], rows * 14)), .06)
    grid = g.math('MAXIMUM', lines[0], lines[1])
    cell_tex = g.node('ShaderNodeTexNoise', Scale=90.0, Detail=2.0)
    cell = g.mix(srgb('#101830'), srgb('#1C2848'), cell_tex.outputs['Fac'])
    col = g.mix(cell, srgb('#3A4460'), g.math('MULTIPLY', fingers, .5))
    col = g.mix(col, srgb('#D5DAE2'), grid)
    g.set(**{'Base Color': col, 'Roughness': g.mix(.12, .5, grid, data_type='FLOAT'), 'Coat Weight': 1.0,
             'Coat Roughness': .03, 'Specular IOR Level': .6})
    return g.mat


def pack_materials():
    fabric('pack_nylon', '#262729', '#121213', '#4C4D50', 'fabric_pattern_07', 22.0, normal=1.4, rough=.75,
           sheen=.15, grime=.55, edge=.5)
    fabric('pack_olive', '#5C5943', '#2C2B20', '#8C8969', 'Fabric030', 14.0, normal=1.0, rough=.85, grime=.55)
    fabric('pack_cream', '#B7AC93', '#6A6150', '#D8D0BA', 'cotton_jersey', 14.0, normal=.8, rough=.85, grime=.6,
           edge=.5)
    fabric('pack_tan', '#977F5C', '#4E4030', '#C0A880', 'Fabric030', 14.0, normal=1.0, rough=.85, grime=.55)
    plastic('bot_shell', '#D3CAB6', .42, '#6A6252', '#F2EEE4', .6, .6)
    plastic('bot_joint', '#1C1C1D', .4, '#0A0A0A', '#5A5A5C', .4, .7)
    emissive('status_heart', '#2EC6C2', 7.0)
    solar_cells()


# Generic materials every character can use; a spec's PALETTE adds its garment colours and may
# override any of these by name.
DEFAULTS = {
    'hair': hair, 'hair_cap': hair_cap, 'glass': glass,
    'leather': lambda: leather('leather'),
    'leather_dark': lambda: leather('leather_dark', '#3E2616', '#1A0F08', '#6E4A32'),
    'leather_tan': lambda: leather('leather_tan', '#8A5530', '#3A200F', '#C08050', 'brown_leather', 9.0),
    'leather_belt': lambda: leather('leather_belt', '#5A3620', '#24140B', '#8C5E3E', 'brown_leather', 12.0),
    'webbing': lambda: webbing('webbing', '#2B2C2E', '#141415', '#505256'),
    'webbing_grey': lambda: webbing('webbing_grey', '#4A4A48', '#232322', '#77756F'),
    'webbing_khaki': lambda: webbing('webbing_khaki', '#8A7A5A', '#4A3F2C', '#B5A47E'),
    'lace': lambda: webbing('lace', '#2A2724', '#141210', '#4A433C', 80.0),
    'steel': lambda: metal('steel', '#8E9296', .34),
    'brass': lambda: metal('brass', '#9C7A3E', .38, '#D8B878'),
    'frame': lambda: metal('frame', '#5E6368', .3),
    'device': lambda: metal('device', '#8C9196', .4),
    'silver': lambda: metal('silver', '#C9CBCF', .22),
    'orange_metal': lambda: metal('orange_metal', '#B8612E', .4, '#E09060'),
    'orange': lambda: plastic('orange', '#BD5E2B', .6, '#5A2A14', '#E08A50'),
    'lens_dark': lambda: plastic('lens_dark', '#0E1216', .08),
    'rubber_grip': lambda: plastic('rubber_grip', '#1E1E1F', .75),
    'button': lambda: plastic('button', '#D8D0C0', .35, '#8A8070', '#FFFFFF', .3, .2),
    'rubber': rubber, 'suede': suede, 'mesh_fabric': mesh_fabric,
    'sock': lambda: fabric('sock', '#2A2A2C', '#141415', '#4A4A4C', 'cotton_jersey', 20.0),
    'pack_nylon': pack_materials,
    'glove_fabric': lambda: neoprene('glove_fabric'),
    'suede_pad': lambda: suede('suede_pad', '#9A7A42', '#4E3C1E', '#C9A86A'),
    'midsole': lambda: plastic('midsole', '#3C3A37', .8, '#1A1918', '#5C5853', .4, .2),
}
