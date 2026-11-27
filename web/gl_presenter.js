const VS_SRC = `#version 300 es
out vec2 v_uv;
void main() {
  vec2 pos = vec2(
    gl_VertexID == 1 ? 3.0 : -1.0,
    gl_VertexID == 2 ? 3.0 : -1.0
  );
  v_uv = vec2((pos.x + 1.0) * 0.5, (1.0 - pos.y) * 0.5);
  gl_Position = vec4(pos, 0.0, 1.0);
}
`;

const FS_SRC = `#version 300 es
precision highp float;
uniform sampler2D u_tex;
in vec2 v_uv;
out vec4 outColor;
void main() {
  outColor = texture(u_tex, v_uv);
}
`;

function compileShader(gl, type, src) {
  const sh = gl.createShader(type);
  gl.shaderSource(sh, src);
  gl.compileShader(sh);
  if (!gl.getShaderParameter(sh, gl.COMPILE_STATUS)) {
    const msg = gl.getShaderInfoLog(sh) || "shader compile failed";
    gl.deleteShader(sh);
    throw new Error(msg);
  }
  return sh;
}

export function createPresenter(canvas) {
  let gl = null;
  try {
    gl = canvas.getContext("webgl2", {
      alpha: false,
      antialias: false,
      depth: false,
      stencil: false,
      powerPreference: "high-performance",
    });
  } catch (_) {
    gl = null;
  }

  if (gl) {
    try {
      const vs = compileShader(gl, gl.VERTEX_SHADER, VS_SRC);
      const fs = compileShader(gl, gl.FRAGMENT_SHADER, FS_SRC);
      const prog = gl.createProgram();
      gl.attachShader(prog, vs);
      gl.attachShader(prog, fs);
      gl.linkProgram(prog);
      gl.deleteShader(vs);
      gl.deleteShader(fs);
      if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
        const msg = gl.getProgramInfoLog(prog) || "program link failed";
        gl.deleteProgram(prog);
        throw new Error(msg);
      }

      const vao = gl.createVertexArray();
      const tex = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, tex);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      gl.pixelStorei(gl.UNPACK_ALIGNMENT, 4);

      gl.useProgram(prog);
      const uTexLoc = gl.getUniformLocation(prog, "u_tex");
      gl.uniform1i(uTexLoc, 0);

      let texW = 0;
      let texH = 0;

      return {
        isWebGL: true,
        resize(cssW, cssH, dpr = 1) {
          const scale = Math.max(1, dpr || 1);
          const bw = Math.max(1, Math.round(cssW * scale));
          const bh = Math.max(1, Math.round(cssH * scale));
          if (canvas.width !== bw || canvas.height !== bh) {
            canvas.width = bw;
            canvas.height = bh;
          }
          gl.viewport(0, 0, bw, bh);
        },
        upload(w, h, pixels) {
          gl.bindTexture(gl.TEXTURE_2D, tex);
          if (w !== texW || h !== texH) {
            texW = w;
            texH = h;
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
          } else {
            gl.texSubImage2D(gl.TEXTURE_2D, 0, 0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
          }
        },
        draw() {
          if (texW <= 0 || texH <= 0) return;
          gl.useProgram(prog);
          gl.bindVertexArray(vao);
          gl.activeTexture(gl.TEXTURE0);
          gl.bindTexture(gl.TEXTURE_2D, tex);
          gl.drawArrays(gl.TRIANGLES, 0, 3);
        },
      };
    } catch (err) {
      console.warn("WebGL2 setup failed, falling back to Canvas2D:", err);
    }
  }

  const ctx = canvas.getContext("2d", { alpha: false });
  let imgData = null;
  let texW = 0;
  let texH = 0;

  return {
    isWebGL: false,
    resize() {},
    upload(w, h, pixels) {
      if (!imgData || w !== texW || h !== texH || canvas.width !== w || canvas.height !== h) {
        texW = w;
        texH = h;
        canvas.width = w;
        canvas.height = h;
        imgData = ctx.createImageData(w, h);
      }
      imgData.data.set(pixels);
    },
    draw() {
      if (imgData) ctx.putImageData(imgData, 0, 0);
    },
  };
}
