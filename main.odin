package main

import "core:math"
import rl "vendor:raylib"

View :: enum {
	Exploded,
	Vector,
}

FONT_SIZE :: 10

START_ANGLE_DEFAULT :: f32(90.0)
START_ANGLE_MIN :: f32(0.0)
START_ANGLE_MAX :: f32(360)

OUTER_R_DEFAULT :: f32(150.0)
OUTER_R_MIN :: f32(24.0)
OUTER_R_MAX :: f32(200.0)

INNER_R_PERCENT_DEFAULT :: f32(38.2)
INNER_R_PERCENT_MIN :: f32(1.0)
INNER_R_PERCENT_MAX :: f32(100.0)

PAD1 :: 4
PAD2 :: 8
PAD3 :: 16

SCREEN_W :: 848
SCREEN_H :: 600
TARGET_FRAME_RATE :: 60

CONTROL_W :: 125
CONTROL_H :: 25
CONTROL_LABEL_W :: 80
CONTROL_VALUE_W :: 35

CONTENT_LEFT :: PAD3 + CONTROL_LABEL_W + CONTROL_W + CONTROL_VALUE_W + PAD2
CONTENT_TOP :: PAD3
CONTENT_W :: SCREEN_W - CONTENT_LEFT - PAD3
CONTENT_H :: SCREEN_H - PAD3 - PAD3
CONTENT_CX :: CONTENT_LEFT + CONTENT_W / 2
CONTENT_CY :: CONTENT_TOP + CONTENT_H / 2

STAR_NUMBER_OF_VERTICES :: 10
STAR_ANGLE_STEP :: -f32(math.TAU) / f32(STAR_NUMBER_OF_VERTICES)

D :: f32(10.0) // This could be animated, too. Food for thought.

DOT_SIZE :: 3

VALUE_STEP :: 10

draw_star :: proc(start_angle, cx, cy, outer_r, inner_r: f32, color: rl.Color) {
	draw_section :: #force_inline proc(origin, v1, v2, v3: [2]f32, color: rl.Color) {
		rl.DrawTriangle(v1, v2, v3, color)
		rl.DrawTriangle(origin, v1, v3, color)
	}

	origin := [2]f32{cx, cy}

	vertices: [STAR_NUMBER_OF_VERTICES][2]f32
	for &vertex, i in vertices {
		angle := -f32(math.to_radians(start_angle)) + f32(i) * STAR_ANGLE_STEP
		radius := outer_r if i % 2 == 0 else inner_r
		vertex = [2]f32{cx + radius * math.cos(angle), cy + radius * math.sin(angle)}
	}

	draw_section(origin, vertices[1], vertices[2], vertices[3], color)
	draw_section(origin, vertices[3], vertices[4], vertices[5], color)
	draw_section(origin, vertices[5], vertices[6], vertices[7], color)
	draw_section(origin, vertices[7], vertices[8], vertices[9], color)
	draw_section(origin, vertices[9], vertices[0], vertices[1], color)
}

draw_star_exploded :: proc(start_angle, cx, cy, outer_r, inner_r: f32) {
	draw_section :: proc(origin, v1, v2, v3: [2]f32, color: rl.Color, label_a, label_b: cstring) {
		a0 := v1 - origin
		b0 := v2 - origin
		c0 := v3 - origin

		r := math.sqrt(math.pow(a0.x, 2.0) + math.pow(a0.y, 2.0))

		scale := (r + D) / r
		o := [2]f32{(a0.x + c0.x) / (2.0 * r) * D, (a0.y + c0.y) / (2.0 * r) * D} + origin
		a := a0 * scale + origin
		c := c0 * scale + origin
		rl.DrawTriangle(o, a, c, color)

		scale = (r + 2.0 * D) / r
		a = a0 * scale + origin
		b := b0 * scale + origin
		c = c0 * scale + origin
		rl.DrawTriangle(a, b, c, color)

		stroke := rl.Color{0, 0, 0, 128}
		rl.DrawLine(i32(origin.x), i32(origin.y), i32(a.x), i32(a.y), stroke)
		rl.DrawLine(i32(origin.x), i32(origin.y), i32(b.x), i32(b.y), stroke)

		rl.DrawCircle(i32(a.x), i32(a.y), DOT_SIZE, rl.BLACK)
		rl.DrawCircle(i32(b.x), i32(b.y), DOT_SIZE, rl.BLACK)

		scale = (r + 4.0 * D) / r
		a = a0 * scale + origin
		rl.DrawText(label_a, i32(a.x), i32(a.y), FONT_SIZE, rl.BLACK)

		scale = (r + 2.5 * D) / r
		b = b0 * scale + origin
		rl.DrawText(label_b, i32(b.x), i32(b.y), FONT_SIZE, rl.BLACK)
	}

	origin := [2]f32{cx, cy}

	vertices: [STAR_NUMBER_OF_VERTICES][2]f32
	for &vertex, i in vertices {
		angle := -f32(math.to_radians(start_angle)) + f32(i) * STAR_ANGLE_STEP
		radius := outer_r if i % 2 == 0 else inner_r
		vertex = [2]f32{cx + radius * math.cos(angle), cy + radius * math.sin(angle)}
	}

	draw_section(origin, vertices[1], vertices[2], vertices[3], rl.GOLD, "1", "2")
	draw_section(origin, vertices[3], vertices[4], vertices[5], rl.LIME, "3", "4")
	draw_section(origin, vertices[5], vertices[6], vertices[7], rl.BLUE, "5", "6")
	draw_section(origin, vertices[7], vertices[8], vertices[9], rl.VIOLET, "7", "8")
	draw_section(origin, vertices[9], vertices[0], vertices[1], rl.RED, "9", "0")
}

main :: proc() {
	rl.InitWindow(SCREEN_W, SCREEN_H, "Stars")
	defer rl.CloseWindow()

	rl.SetTargetFPS(TARGET_FRAME_RATE)
	rl.SetExitKey(rl.KeyboardKey.KEY_NULL)

	view := View.Exploded

	start_angle := START_ANGLE_DEFAULT
	outer_r := OUTER_R_DEFAULT
	inner_r_percent := INNER_R_PERCENT_DEFAULT

	show_fps := false

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawLine(
			CONTENT_LEFT,
			CONTENT_TOP + CONTENT_H / 2,
			CONTENT_LEFT + CONTENT_W,
			CONTENT_TOP + CONTENT_H / 2,
			rl.SKYBLUE,
		)
		rl.DrawLine(
			CONTENT_LEFT + CONTENT_W / 2,
			CONTENT_TOP,
			CONTENT_LEFT + CONTENT_W / 2,
			CONTENT_TOP + CONTENT_H,
			rl.SKYBLUE,
		)

		if start_angle > 0 {
			color := rl.PINK
			color.a = 64
			rl.DrawCircleSector(
				[2]f32{CONTENT_CX, CONTENT_CY},
				f32(CONTENT_W / 2 - PAD2),
				0.0,
				-start_angle,
				64,
				color,
			)
		}

		inner_r := outer_r * inner_r_percent / 100.0

		if view == .Exploded {
			draw_star_exploded(start_angle, CONTENT_CX, CONTENT_CY, outer_r, inner_r)
		}
		if view == .Vector {
			draw_star(start_angle, CONTENT_CX, CONTENT_CY, outer_r, inner_r, rl.BLACK)
		}

		control_x: f32 = PAD3 + CONTROL_LABEL_W
		control_y: f32 = PAD3
		rl.GuiSliderBar(
			rl.Rectangle{control_x, control_y, CONTROL_W, CONTROL_H},
			"start angle °",
			rl.TextFormat("%.2f", start_angle),
			&start_angle,
			START_ANGLE_MIN,
			START_ANGLE_MAX,
		)
		if rl.IsKeyPressed(rl.KeyboardKey.UP) || rl.IsKeyPressedRepeat(rl.KeyboardKey.UP) {
			start_angle += VALUE_STEP
			start_angle = math.max(math.min(start_angle, START_ANGLE_MAX), START_ANGLE_MIN)
		}
		if rl.IsKeyPressed(rl.KeyboardKey.DOWN) || rl.IsKeyPressedRepeat(rl.KeyboardKey.DOWN) {
			start_angle -= VALUE_STEP
			start_angle = math.max(math.min(start_angle, START_ANGLE_MAX), START_ANGLE_MIN)
		}

		control_y += CONTROL_H + PAD1
		rl.GuiSliderBar(
			rl.Rectangle{control_x, control_y, CONTROL_W, CONTROL_H},
			"outer radius",
			rl.TextFormat("%.2f", outer_r),
			&outer_r,
			OUTER_R_MIN,
			OUTER_R_MAX,
		)
		control_y += CONTROL_H + PAD1
		rl.GuiSliderBar(
			rl.Rectangle{control_x, control_y, CONTROL_W, CONTROL_H},
			"inner radius %",
			rl.TextFormat("%.2f", inner_r_percent),
			&inner_r_percent,
			INNER_R_PERCENT_MIN,
			INNER_R_PERCENT_MAX,
		)
		if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) || rl.IsKeyPressedRepeat(rl.KeyboardKey.RIGHT) {
			if rl.IsKeyDown(rl.KeyboardKey.LEFT_ALT) || rl.IsKeyDown(rl.KeyboardKey.RIGHT_ALT) {
				inner_r_percent += VALUE_STEP
				inner_r_percent = math.max(
					math.min(inner_r_percent, INNER_R_PERCENT_MAX),
					INNER_R_PERCENT_MIN,
				)
			} else {
				outer_r += VALUE_STEP
				outer_r = math.max(math.min(outer_r, OUTER_R_MAX), OUTER_R_MIN)
			}
		}
		if rl.IsKeyPressed(rl.KeyboardKey.LEFT) || rl.IsKeyPressedRepeat(rl.KeyboardKey.LEFT) {
			if rl.IsKeyDown(rl.KeyboardKey.LEFT_ALT) || rl.IsKeyDown(rl.KeyboardKey.RIGHT_ALT) {
				inner_r_percent -= VALUE_STEP
				inner_r_percent = math.max(
					math.min(inner_r_percent, INNER_R_PERCENT_MAX),
					INNER_R_PERCENT_MIN,
				)
			} else {
				outer_r -= VALUE_STEP
				outer_r = math.max(math.min(outer_r, OUTER_R_MAX), OUTER_R_MIN)
			}
		}

		control_y += CONTROL_H + PAD3
		if rl.IsKeyPressed(rl.KeyboardKey.E) ||
		   rl.GuiButton(rl.Rectangle{control_x, control_y, CONTROL_W, CONTROL_H}, "exploded") {
			view = .Exploded
		}

		control_y += CONTROL_H + PAD1
		if rl.IsKeyPressed(rl.KeyboardKey.V) ||
		   rl.GuiButton(rl.Rectangle{control_x, control_y, CONTROL_W, CONTROL_H}, "vector") {
			view = .Vector
		}

		control_y += CONTROL_H + PAD3
		if rl.IsKeyPressed(rl.KeyboardKey.R) ||
		   rl.GuiButton(rl.Rectangle{control_x, control_y, CONTROL_W, CONTROL_H}, "reset") {
			start_angle = START_ANGLE_DEFAULT
			outer_r = OUTER_R_DEFAULT
			inner_r_percent = INNER_R_PERCENT_DEFAULT
		}

		if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
			show_fps = !show_fps
		}
		if show_fps {
			control_x = PAD3
			control_y = SCREEN_H - PAD3 - FONT_SIZE
			rl.DrawText(
				rl.TextFormat("%d fps", rl.GetFPS()),
				i32(control_x),
				i32(control_y),
				FONT_SIZE,
				rl.DARKGRAY,
			)
		}

		view_label: cstring = "vector" if view == .Vector else "exploded"
		control_x = f32(SCREEN_W - rl.MeasureText(view_label, FONT_SIZE) - PAD3)
		control_y = PAD3
		rl.DrawText(view_label, i32(control_x), i32(control_y), FONT_SIZE, rl.DARKGRAY)
	}
}
