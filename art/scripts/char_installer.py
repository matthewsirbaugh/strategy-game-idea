"""The Installer (direction C concept): character spec for the shared human kit in human/.

    blender --background --factory-startup --python art/scripts/char_installer.py -- [--from STAGE] [--to STAGE]

Her body is also the reference mannequin every garment builder is tuned to. How the kit works and
what it learned is in art/human-pipeline.md.
"""
import sys
from pathlib import Path
import bmesh
from mathutils import Vector

sys.path.insert(0, str(Path(__file__).resolve().parent))
from human import (build, garments as G, materials as M, trousers, shirt, vest, shoes, gear, head,  # noqa: E402
                   accessories, backpack, gloves, decals)
from human.details import tree, conform_box, snap  # noqa: E402
from human.gear import finish  # noqa: E402

NAME = 'char_installer'
BASE = 'art/vendor/installer_base.blend'
CONCEPT = 'art/concepts/installer-2026-09-26/direction-c-turnaround.png'

# Regenerate the base with: blender -b --factory-startup -P art/scripts/make_base.py -- char_installer
BODY = dict(
    macros=dict(gender=0.0, age=.5, muscle=.62, weight=.36, proportions=.62, cupsize=.34, firmness=.6,
                race={'african': .5, 'asian': .12, 'caucasian': .38}),
    # likeness: oval face, high cheekbones, fuller lips, finer nose; a relaxed, slightly amused expression
    face={'head/head-oval': .45, 'cheek/l-cheek-bones-incr': .45, 'cheek/r-cheek-bones-incr': .45,
          'cheek/l-cheek-volume-decr': .2, 'cheek/r-cheek-volume-decr': .2,
          'mouth/mouth-lowerlip-volume-incr': .15, 'mouth/mouth-upperlip-volume-incr': .55,
          'mouth/mouth-upperlip-height-incr': .35, 'mouth/mouth-cupidsbow-incr': .35, 'mouth/mouth-angles-up': .12,
          'mouth/mouth-lowerlip-ext-up': .2, 'nose/nose-point-width-decr': .3, 'nose/nose-nostrils-width-decr': .2,
          'nose/nose-scale-horiz-decr': .12, 'chin/chin-width-decr': .25, 'chin/chin-prominent-incr': .15,
          'eyebrows/eyebrows-angle-up': .2, 'neck/neck-scale-horiz-decr': .15,
          'expression/units/african/mouth-corner-puller': .2, 'expression/units/caucasian/mouth-corner-puller': .12,
          'expression/units/african/eye-left-slit': .1, 'expression/units/african/eye-right-slit': .1},
    eyes='brown', brows='eyebrow008', lashes='eyelashes01',
    skin=('skins01_cc0/skins/cutoff3d_indian_female_enhanced/indian_skin3e.png', 'skin_indian_female_enhanced.png'),
    height=1.653,
)
LOOK = {}   # body.LOOK defaults are hers

PALETTE = {
    'shirt': lambda: M.fabric('shirt', '#7A3022', '#3E170F', '#A04B34', 'stretch_poplin', 9.0, normal=.9, rough=.82,
                              sheen=.35, grime=.6, edge=.45, fade_scale=4.0),
    'vest': lambda: M.fabric('vest', '#2A4450', '#121F26', '#557B88', 'denim_fabric_06', 6.0, normal=1.2, rough=.88,
                             sheen=.15, grime=.7, edge=.6, fade_scale=4.0),
    'trousers': lambda: M.fabric('trousers', '#333436', '#18191A', '#625E58', 'denim_fabric_05', 6.0, normal=1.1,
                                 rough=.9, sheen=.12, grime=.7, edge=.55, fade_scale=3.0),
    'headband': lambda: M.fabric('headband', '#77301F', '#3E170E', '#A04A34', 'cotton_jersey', 10.0, normal=.8,
                                 rough=.86, sheen=.3, grime=.45, edge=.3),
}


def stage_trousers(ctx):
    t = trousers.shell(ctx.body, ctx.col)
    trousers.drape(t, ctx.body, ctx.col)
    G.dress(t, ctx.mat('trousers'), .0022)


def stage_shirt(ctx):
    s, frames = shirt.shell(ctx.body, ctx.rig, ctx.col)
    shirt.drape(s, frames, ctx.body, ctx.col)
    shirt.roll_cuffs(s, frames, ctx.col, ctx.mat('shirt'))
    shirt.collar_and_placket(s, ctx.col, ctx.mat('shirt'), ctx.mat('button'))
    G.dress(s, ctx.mat('shirt'), .0018)


def stage_vest(ctx):
    v = vest.shell(ctx.body, ctx.col)
    col = vest.collar(v, ctx.col)
    vest.settle(v, ctx.obj('shirt'), ctx.body)
    for o in (v, col):
        G.dress(o, ctx.mat('vest'), .0035)


def stage_shoes(ctx):
    mats = ctx.mats
    mats['shoe_mesh'] = mats['mesh_fabric']
    shoes.build(ctx.body, ctx.col, mats)


def stage_gear(ctx):
    t, mats = ctx.obj('trousers'), ctx.mats
    gear.belt(t, ctx.col, mats)
    gear.belt_loops(t, ctx.col, mats['trousers'])
    gear.hip_pouch(t, ctx.col, mats)
    gear.carabiners(t, ctx.col, mats)
    gear.thigh_rig(t, ctx.col, mats)
    gear.tool_sheath(t, ctx.col, mats)


def stage_head(ctx):
    head.headband(ctx.body, ctx.col, ctx.mat('headband'))
    cap = head.scalp_cap(ctx.body, ctx.col, ctx.mat('hair_cap'))
    head.hair(ctx.body, cap, ctx.col, ctx.mat('hair'))
    accessories.glasses(ctx.body, ctx.col, ctx.mat('glass'), ctx.mat('frame'), ctx.mat('device'), ctx.mat('lens_dark'))
    accessories.earrings(ctx.body, ctx.col, ctx.mat('silver'))


def stage_backpack(ctx):
    backpack.build(ctx.obj('vest'), ctx.col, ctx.mats)


def stage_gloves(ctx):
    gloves.build(ctx.body, ctx.rig, ctx.col, ctx.mats)


def stage_details(ctx):
    """Her pockets, snaps, leaf emblem and sewn patches, placed on the reference mannequin."""
    col, mats = ctx.col, ctx.mats
    t = tree(ctx.obj('vest'))
    snaps = bmesh.new()
    for s, side in ((-1, 'r'), (1, 'l')):
        conform_box(t, f'vest_pocket_{side}', (s * .085, -.14, 1.035), (0, 0, 1), .115, .075, .006, col, mats['vest'], .003)
        _, (floc, fside, fup, _) = conform_box(t, f'vest_flap_{side}', (s * .085, -.15, 1.07), (0, 0, 1), .125, .042,
                                               .006, col, mats['vest'], .011, round_bottom=.25)
        for k in (-1, 1):
            hit, hn, _, _ = t.find_nearest(floc + fside * k * .035 - fup * .008)
            snap(snaps, hit + hn * .02, hn)
    for z in (1.02, 1.09, 1.16, 1.23, 1.30):
        hit = t.ray_cast(Vector((.045, -.4, z)), Vector((0, 1, 0)))
        if hit[0] is not None:
            snap(snaps, hit[0] + hit[1] * .0045, hit[1], .005)
    finish('vest_snaps', snaps, col, mats['brass'])
    emblem = decals.decal_material('vest_emblem', decals.leaf_emblem(), .85)
    decals.patch_on(ctx.obj('vest'), 'vest_emblem', (-.075, -.16, 1.2), (0, 0, 1), .095, .12, col, emblem, .0065, 28)
    t = tree(ctx.obj('trousers'))
    conform_box(t, 'cargo_pocket', (.19, -.01, .62), (0, 0, 1), .13, .15, .008, col, mats['trousers'], .003)
    _, (floc, _, fup, _) = conform_box(t, 'cargo_flap', (.192, -.012, .71), (0, 0, 1), .14, .05, .006, col,
                                       mats['trousers'], .012, round_bottom=.2)
    for s, side in ((1, 'l'), (-1, 'r')):
        conform_box(t, f'back_pocket_{side}', (s * .075, .14, .845), (0, 0, 1), .12, .13, .004, col, mats['trousers'], .002)
    snaps = bmesh.new()
    hit, hn, _, _ = t.find_nearest(floc - fup * .012)
    snap(snaps, hit + hn * .02, hn)
    finish('cargo_snap', snaps, col, mats['brass'])
    knee = decals.decal_material('knee_patch', decals.stitched_patch('installer_knee_patch', (.42, .38, .33),
                                                                     (.25, .33, .5)), .9)
    decals.patch_on(ctx.obj('trousers'), 'knee_patch', (-.14, -.12, .53), (0, 0, 1), .085, .09, col, knee, .0035)
    sleeve = decals.decal_material('sleeve_patch', decals.stitched_patch('installer_sleeve_patch', (.22, .23, .27),
                                                                         (.12, .14, .2), darn=True), .9)
    decals.patch_on(ctx.obj('shirt'), 'sleeve_patch', (-.245, -.02, 1.24), (.55, 0, .83), .07, .06, col, sleeve, .003)


STAGES = [('trousers', stage_trousers), ('shirt', stage_shirt), ('vest', stage_vest), ('shoes', stage_shoes),
          ('gear', stage_gear), ('head', stage_head), ('backpack', stage_backpack), ('gloves', stage_gloves),
          ('details', stage_details)]

# Parts that ride a single bone instead of copying the body's weights.
BONES = ((('headband', 'hair', 'glasses_', 'earring_'), 'head'), (('pack_', 'solar_', 'bottle', 'bot_'), 'spine_03'),
         (('hip_pouch', 'carabiner_', 'tool_sheath', 'tool_grip'), 'pelvis'),
         (('thigh_holster', 'thigh_tool', 'thigh_drop_strap'), 'thigh_r'))
# When the outfit moves to another body: each group keeps its shape and moves as one piece...
RIGID = (('glasses_',), ('earring_l',), ('earring_r',), ('belt_buckle',), ('hip_pouch',), ('carabiner_0',),
         ('carabiner_1',), ('carabiner_2',), ('tool_sheath', 'tool_grip'), ('thigh_holster', 'thigh_tool'),
         ('pack_', 'solar_', 'bottle', 'bot_'))
# ...and footwear rides the foot bones, scaled to the new feet.
ON_BONES = ((('shoe_l', 'shoe_collar_l', 'shoe_tongue_l', 'sole_l', 'laces_l', 'eyelets_l', 'heel_tab_l'), 'foot_l'),
            (('shoe_r', 'shoe_collar_r', 'shoe_tongue_r', 'sole_r', 'laces_r', 'eyelets_r', 'heel_tab_r'), 'foot_r'))
# Garments that hide the skin under them.
COVER = ('trousers', 'shirt', 'vest', 'socks', 'hair_cap', 'shoe_l', 'shoe_r', 'glove_l', 'glove_r')
TUCK = [('shirt', 'trousers', .003, .958)]
EXPORT = dict(
    ratios=(('shirt', .08), ('trousers', .12), ('vest_collar', .3), ('vest', .12), ('socks', .3), ('hair_cap', .3),
            ('hair', .08), ('headband_knot', .3), ('headband', .25), ('shoe_collar', .4), ('shoe_tongue', .5),
            ('shoe_', .05), ('glove_l', .12), ('glove_r', .12), ('body', .45), ('eyes', .5), ('belt', .5),
            ('tool_belt', .5), ('sole_', .6), ('bot_arm', .5), ('shoulder_strap', .6)),
    cloth=('shirt', 'trousers', 'vest', 'socks', 'headband', 'hair_cap', 'cargo_', 'back_pocket', 'belt_loops'),
    gear_in_cloth=('shirt_buttons', 'vest_snaps', 'cargo_snap'),
    decals=('vest_emblem', 'knee_patch', 'sleeve_patch'),
    special=('hair', 'glasses_lenses', 'glasses_pads', 'bot_lens'),
    flat={'hair': '#2A1B12'}, glass=('glasses_lenses', 'glasses_pads'), heart={'bot_lens': '#2EC6C2'},
)

if __name__ == '__main__':
    build.run(sys.modules[__name__])
