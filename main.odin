package main

import "core:fmt"
import "core:image"
import png "core:image/png"
import "vendor:glfw"
import gl "vendor:OpenGL"


main :: proc() {
    glfw.WindowHint(glfw.RESIZABLE, 1)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)


    if(glfw.Init() != 1){
		fmt.println("Failed to initialize GLFW")
		return
	}    
	defer glfw.Terminate()

    window := glfw.CreateWindow(1200, 800, "Earth", nil, nil)
    defer glfw.DestroyWindow(window)

    if window == nil {
		fmt.println("Unable to create window")
		return
	}
        
    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)

    glfw.SetKeyCallback(window, key_callback)
	glfw.SetFramebufferSizeCallback(window, size_callback)


    gl.load_up_to(3,3, glfw.gl_set_proc_address)


    vertex_data := [?]f32{
        -0.5,  0.5,   0, 0,
        -0.5, -0.5,   0, 1.0,
         0.5, -0.5,   1.0, 1.0,
        -0.5,  0.5,   0, 0,
         0.5,  0.5,   1.0, 0,
         0.5, -0.5,   1.0, 1.0,
    }

    vao : u32

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    vbo : u32
    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

    texture : u32
    gl.GenTextures(1, &texture)
    gl.BindTexture(gl.TEXTURE_2D, texture)
    
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertex_data), &vertex_data, gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 0 * size_of(f32))
    gl.EnableVertexAttribArray(0)

    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 2 * size_of(f32))    
    gl.EnableVertexAttribArray(1)


    shaders : u32
    shader_success : bool

    shaders, shader_success = gl.load_shaders_source(
        #load("resources/shaders/vertex.glsl"),
        #load("resources/shaders/fragment.glsl"),
    );
    defer gl.DeleteProgram(shaders);

    if !shader_success {
        fmt.println("ERROR: Failed to load and compile shaders.")
        return
    }


    image_file_bytes    := #load("resources/hummingbird.png")

    image_ptr           :  ^image.Image
    err                 :  image.Error
    options             := image.Options{.alpha_add_if_missing}

    image_ptr, err = png.load_from_bytes(image_file_bytes, options)
    defer png.destroy(image_ptr)
    image_width := i32(image_ptr.width)
    image_height := i32(image_ptr.height)

    if err != nil {
        fmt.println("ERROR: Image:", "resources/hummingbird.png", "failed to load.")
    }

    pixels_u8 := make([]u8, len(image_ptr.pixels.buf))
    for b, i in image_ptr.pixels.buf {
        pixels_u8[i] = b
    }

    gl.TexImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        image_width,
        image_height,
        0,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        &pixels_u8[0],
    )

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    gl.Enable(gl.BLEND);


    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        
        gl.UseProgram(shaders)
        gl.BindVertexArray(vao)
        defer gl.BindVertexArray(0)
        
        gl.ClearColor(0.1, 0.1, 0.1, 1)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.DrawArrays(gl.TRIANGLES, 0, 6)
        glfw.SwapBuffers(window)
    }
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if key == glfw.KEY_ESCAPE {
		glfw.SetWindowShouldClose(window, true)
	}
}

size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}
