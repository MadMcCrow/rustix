// entry point of my game
use bevy::prelude::*;
mod map;

fn main() {
    App::new()
    .add_plugins((DefaultPlugins, map::MapPlugin))
    .run();
}
