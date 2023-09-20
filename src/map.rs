use std::ptr::null;

use bevy::prelude::* ;

struct MapCoord{
    x:i16,
    y:i16
} // Max is 32_767, for i32 it's 2_147_483_647

// Map is the total size of the map
#[derive(Resource)]
struct Map(MapCoord);

// Tile component is just a position
#[derive(Component)]
struct Tile(MapCoord);

#[derive(Component)]
struct TileHeight(i16);

// 
#[derive(Component)]
struct TileModifier();

#[derive(Component)]
struct TileMesh();

// spawn the components
fn spawn_map(map: Res<Map>, mut commands: Commands) {
    let x_max = map.0.x;
    let y_max = map.0.y;

    // spawn components
    for x in 0..x_max {
        for y in 0..y_max {
            commands.spawn(( Tile(MapCoord { x:x, y:y }),TileHeight(0),TileMesh() ));
        }
    }
}

// gen the tile heights
fn gen_map(query: Query<&Tile,With<TileHeight>>) {
    let mut t = 0;
    for tile in &query {
        t = t + i64::from(tile.0.x) + i64::from(tile.0.y); 
    }
    println!("total = {}", t);
}

// update the map given all the tiles
fn update_map(query: Query<&Tile>) {
}

// draw all the tiles on screen
fn draw_map(query: Query<&Tile, With<TileMesh>>){

}

// All map system as a plugin
pub struct MapPlugin;
impl Plugin for MapPlugin {
    fn build(&self, app: &mut App) {
        app
        .insert_resource(Map(MapCoord { x: 1000, y: 1000 }))
        .add_systems(Startup, spawn_map)
        .add_systems(PostStartup, gen_map)
        .add_systems(Update, update_map);
    }
}
