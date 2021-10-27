defmodule The3dPicking do
  @moduledoc false

  alias Rayex.Structs, as: S

  require Logger

  use Rayex

  @cube_position %{x: 0.0, y: 1.0, z: 0.0}
  @mouse_left 0
  @color_white %{r: 245, g: 245, b: 245, a: 255}
  @color_darkgray %{r: 80, g: 80, b: 80, a: 255}
  @color_gray %{r: 130, g: 130, b: 130, a: 255}
  @color_red %{r: 230, g: 41, b: 55, a: 255}
  @color_maroon %{r: 190, g: 33, b: 55, a: 255}
  @color_green %{r: 0, g: 228, b: 48, a: 255}

  def run do
    init_window(800, 450, "raylib [core] example - 3d picking")
    set_target_fps(60)

    camera = %S.Camera3D{
      position: %{x: 10.0, y: 10.0, z: 10.0},
      target: %{x: 0.0, y: 0.0, z: 0.0},
      up: %{x: 0.0, y: 1.0, z: 0.0},
      fovy: 45.0,
      projection: 0
    }

    camera_id = set_camera_mode(camera, 1)

    game_loop(%{camera: camera, camera_id: camera_id, hit?: false})
  end

  defp game_loop(%{camera: camera, camera_id: camera_id, hit?: hit?} = state) do
    Logger.debug(inspect(camera))

    ray = get_mouse_position() |> get_mouse_ray(camera)

    hit? =
      if mouse_button_pressed?(@mouse_left) do
        !hit? && check_hit(ray, camera)
      else
        hit?
      end

    state = %{state | hit?: hit?, camera: update_camera(camera)}

    #
    # draw
    #
    begin_drawing()
    clear_background(@color_white)

    # --- 3D ---
    begin_mode_3d(camera)

    if hit? do
      draw_cube(@cube_position, 2.0, 2.0, 2.0, @color_red)
      draw_cube_wires(@cube_position, 2.0, 2.0, 2.0, @color_maroon)
      draw_cube_wires(@cube_position, 2.2, 2.2, 2.2, @color_green)
    else
      draw_cube(@cube_position, 2.0, 2.0, 2.0, @color_gray)
      draw_cube_wires(@cube_position, 2.0, 2.0, 2.0, @color_darkgray)
    end

    draw_ray(ray, @color_maroon)
    draw_grid(10, 1.0)

    end_mode_3d()
    # --- 3D ---

    draw_text("Try selecting the box with mouse!", 240, 10, 20, @color_darkgray)
    draw_fps(10, 10)

    end_drawing()
    #
    # end draw
    #

    (window_should_close() && close_window()) || game_loop(state)
  end

  defp check_hit(ray, camera) do
    collision =
      get_ray_collision_box(
        ray,
        %S.BoundingBox{
          min: %{x: @cube_position.x - 1.0, y: @cube_position.y - 1.0, z: @cube_position.z - 1.0},
          max: %{x: @cube_position.x + 1.0, y: @cube_position.y + 1.0, z: @cube_position.z + 1.0}
        }
      )

    collision.hit
  end
end