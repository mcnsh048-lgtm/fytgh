# Realistic Minecraft Shader Pack v1.0

A comprehensive physically-based rendering shader pack optimized for Minecraft version 26.1.2.

## Features

### Visual Enhancements
- **Physically-Based Rendering (PBR)**: Proper metallic and specular surfaces with realistic material responses
- **Advanced Water Rendering**: Caustics, reflections, refractions, and foam effects
- **Dynamic Lighting**: Volumetric light rays (god rays) from sun and moon
- **Screen-Space Ambient Occlusion (SSAO)**: Enhanced depth perception and surface detail
- **Parallax Occlusion Mapping (POM)**: Detailed surface geometry without additional geometry
- **Normal & Height Maps**: Full support for texture detail enhancement

### Atmospheric Effects
- **Realistic Sky**: HDR tone mapping with accurate color grading
- **Dynamic Clouds**: Volumetric rendering with realistic movement
- **Atmospheric Scattering**: Rayleigh and Mie scattering for accurate light interaction
- **Time-of-Day Transitions**: Smooth lighting transitions throughout day/night cycle
- **Weather Integration**: Rain, snow, and fog effects with shader support

### Performance Optimization
- **4 Quality Tiers**: Ultra, High, Medium, Low settings
- **Configurable Quality**: Shadow quality, draw distance, and effect intensity
- **Adaptive Rendering**: Hardware detection and automatic adjustment
- **v26.1.2 Optimized**: Efficient shader precision and instruction usage

## Installation

1. Download the latest release from the Releases page
2. Extract the `.zip` file to your Minecraft shader mods folder:
   - Windows: `%AppData%\.minecraft\shaderpacks`
   - macOS: `~/Library/Application Support/minecraft/shaderpacks`
   - Linux: `~/.minecraft/shaderpacks`
3. Launch Minecraft and select the shader pack from the Video Settings > Shaders menu
4. Adjust quality settings using the in-game shader menu (default: Right-click shader)

## Configuration

All settings are configurable through the in-game shader menu:
- **Quality Preset**: Select your preferred quality tier
- **Shadow Quality**: Adjust shadow map resolution and filtering
- **Effects**: Enable/disable bloom, motion blur, depth of field
- **Lighting**: Adjust sun/moon intensity and color temperature
- **Water**: Configure water reflectivity and caustic intensity
- **Sky**: Adjust cloud density and atmospheric scattering strength

## System Requirements

- **Minimum**: NVIDIA GTX 660 / AMD R7 260X or equivalent
- **Recommended**: NVIDIA GTX 1060 / AMD RX 580 or better
- **Ultra Settings**: NVIDIA RTX 2070 / AMD RX 5700 XT or better

## Compatibility

- **Minecraft Version**: 1.26.1.2 (Java Edition)
- **Shader Loader**: OptiFine/Iris Shaders
- **GPU Support**: GLSL 1.20+, OpenGL 3.2+

## File Structure

```
Realistic_Shader_Pack_v1.0/
├── shaders/
│   ├── core/
│   │   ├── terrain.vsh / terrain.fsh
│   │   ├── water.vsh / water.fsh
│   │   ├── sky.vsh / sky.fsh
│   │   └── composite.vsh / composite.fsh
│   ├── effects/
│   │   ├── bloom.fsh
│   │   ├── ssao.fsh
│   │   ├── volumetric.fsh
│   │   └── tonemap.fsh
│   └── lib/
│       ├── pbr.glsl
│       ├── lighting.glsl
│       ├── atmosphere.glsl
│       └── util.glsl
├── textures/
│   ├── pbr_maps/
│   ├── normals/
│   ├── parallax/
│   └── sky/
├── shaders.properties
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## Performance Tips

- Start with the "High" preset and adjust based on your FPS
- Disable volumetric effects if experiencing frame drops
- Reduce shadow quality for older GPUs
- Use medium cloud density for better performance

## Known Issues & Fixes

- **Windows 10/11 Issues**: Update your GPU drivers to the latest version
- **Low FPS**: Switch to a lower quality preset
- **Visual Glitches**: Clear shader cache and restart Minecraft

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Support

For issues, suggestions, or contributions, please open an issue or submit a pull request.

## License

MIT License - See LICENSE file for details

## Credits

Developed with inspiration from industry-standard rendering techniques and the Minecraft shader community.
