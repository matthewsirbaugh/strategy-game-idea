"""Small node-building helpers shared by the Installer build."""
from pathlib import Path
import bpy

ROOT = Path(__file__).resolve().parents[3]
VENDOR = ROOT / 'art/vendor'


def srgb(hex_color):
    h = hex_color.lstrip('#')
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(x / 12.92 if x <= .04045 else ((x + .055) / 1.055) ** 2.4 for x in c) + (1.0,)


class Graph:
    """A material under construction: nodes are laid out left to right as they are added."""

    def __init__(self, name, replace=True):
        old = bpy.data.materials.get(name)
        if old and replace:
            bpy.data.materials.remove(old)
        self.mat = bpy.data.materials.new(name)
        self.mat.use_fake_user = True
        self.mat.use_nodes = True
        self.nodes = self.mat.node_tree.nodes
        self.links = self.mat.node_tree.links
        self.bsdf = self.nodes['Principled BSDF']
        self.out = self.nodes['Material Output']
        self._x = -1400

    def node(self, kind, **inputs):
        n = self.nodes.new(kind)
        n.location = (self._x, 300 - 180 * (len(self.nodes) % 6))
        self._x += 60
        for key, value in inputs.items():
            if hasattr(n, key) and key not in n.inputs:
                setattr(n, key, value)
            elif isinstance(value, bpy.types.NodeSocket):
                self.links.new(value, n.inputs[key])
            else:
                n.inputs[key].default_value = value
        return n

    def link(self, a, b):
        self.links.new(a, b)

    def image(self, path, colorspace='sRGB', vector=None, interpolation='Linear'):
        img = bpy.data.images.load(str(path), check_existing=True)
        img.colorspace_settings.name = colorspace
        n = self.node('ShaderNodeTexImage')
        n.image = img
        n.interpolation = interpolation
        if vector is not None:
            self.link(vector, n.inputs['Vector'])
        return n

    def mix(self, a, b, fac, blend='MIX', data_type='RGBA'):
        n = self.nodes.new('ShaderNodeMix')
        n.data_type = data_type
        if data_type == 'RGBA':
            n.blend_type = blend
        n.location = (self._x, -300)
        self._x += 60
        sockets = {'FLOAT': (2, 3, 0), 'RGBA': (6, 7, 0), 'VECTOR': (4, 5, 0)}[data_type]
        for idx, v in zip(sockets, (a, b, fac)):
            sock = n.inputs[idx]
            if isinstance(v, bpy.types.NodeSocket):
                self.link(v, sock)
            else:
                sock.default_value = v
        out = {'FLOAT': 0, 'RGBA': 2, 'VECTOR': 1}[data_type]
        return n.outputs[out]

    def math(self, op, a, b=0.0, clamp=False):
        n = self.nodes.new('ShaderNodeMath')
        n.operation = op
        n.use_clamp = clamp
        n.location = (self._x, -500)
        self._x += 40
        for sock, v in zip(n.inputs, (a, b)):
            if isinstance(v, bpy.types.NodeSocket):
                self.link(v, sock)
            else:
                sock.default_value = v
        return n.outputs[0]

    def ramp(self, fac, stops):
        n = self.nodes.new('ShaderNodeValToRGB')
        n.location = (self._x, -700)
        self._x += 60
        self.link(fac, n.inputs['Fac'])
        els = n.color_ramp.elements
        while len(els) > len(stops):
            els.remove(els[-1])
        while len(els) < len(stops):
            els.new(0.5)
        for el, (pos, color) in zip(els, stops):
            el.position = pos
            el.color = color if len(color) == 4 else tuple(color) + (1.0,)
        return n.outputs['Color']

    def set(self, **inputs):
        for key, value in inputs.items():
            sock = self.bsdf.inputs[key]
            if isinstance(value, bpy.types.NodeSocket):
                self.link(value, sock)
            else:
                sock.default_value = value
        return self
