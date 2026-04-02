# 3DAM
*A simple 3D Asset Manager made with the Godot Engine*

<img width="483" height="278" alt="Screenshot of the 3D-Asset-Managers GUI" src="https://github.com/user-attachments/assets/a011130f-32b9-4477-a425-71d55d7b082a" />

## NOTICE
This project is not yet complete. *Expect a limited feature-set.* <br>
It can be used as a standalone software, or in combination with a custom asset server, which can be found [here](https://github.com/hunsri/3DAM-Server)

## Features

- supports .gltf and .glb files
- allows browsing and organizing assets
- exchange assets with others through [servers](https://github.com/hunsri/3DAM-Server)
    - download
    - share
    - comment and star your favorite assets
- preview interactive 3D models of downloaded assets

## Requirements

Project is on **Godot 4.5.1** <br>
It is recommended to use the same version.
<br><br>
The project should still be able to be run with all Godot 4.x versions.

## Quick Start

1. Open the project folder in Godot.
2. Open and run the main scene: `scenes/MainScene.tscn`.

## Project Structure

- `scenes/` - main scenes, UI components and subscenes
- `scripts/` - GDScript logic for managers, handlers, loaders
- `resources/`, `themes/` - theme and environment resources
- `icons/` - icon assets
