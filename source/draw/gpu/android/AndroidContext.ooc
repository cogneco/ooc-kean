//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
use ooc-android-debug
use ooc-draw-gpu
use ooc-opengl
use ooc-draw
use ooc-math
import GpuPacker, GpuMapAndroid, GpuPackerBin, EglRgba
AndroidContext: class extends OpenGLES3Context {
	_packMonochrome: OpenGLES3MapPackMonochrome
	_packUv: OpenGLES3MapPackUv
	_packerBin: GpuPackerBin
	init: func {
		super()
		this _packMonochrome = OpenGLES3MapPackMonochrome new()
		this _packUv = OpenGLES3MapPackUv new()
		this _packerBin = GpuPackerBin new()
	}
	toRaster: func ~overwrite (gpuImage: GpuImage, rasterImage: RasterImage) {
		if(gpuImage instanceOf?(GpuYuv420Semiplanar)) {
			printAndroid("Packing YUV420")
			rasterYuv420Semiplanar := rasterImage as RasterYuv420Semiplanar
			semiPlanar := gpuImage as GpuYuv420Semiplanar
			yPacker := createPacker(semiPlanar y size, 1)
			//yPacker pack(semiPlanar y, this _packMonochrome, rasterYuv420Semiplanar y)
			yPacker recycle()
			uvPacker := createPacker(semiPlanar uv size, 2)
			//uvPacker pack(semiPlanar uv, this _packUv, rasterYuv420Semiplanar uv)
			uvPacker recycle()
		}
	}
	toRaster: func (gpuImage: GpuImage) -> RasterImage {
		result := null
		if(gpuImage instanceOf?(GpuYuv420Semiplanar)) {
			raster := RasterYuv420Semiplanar new(gpuImage size)
			semiPlanar := gpuImage as GpuYuv420Semiplanar
			yPacker := createPacker(semiPlanar y size, 1)
			yPacker pack(semiPlanar y, this _packMonochrome, raster y)
			yPacker recycle()
			uvPacker := createPacker(semiPlanar uv size, 2)
			uvPacker pack(semiPlanar uv, this _packUv, raster uv)
			uvPacker recycle()
			result = raster
		}
		result
	}
	recycle: func ~GpuPacker (packer: GpuPacker) {
		this _packerBin add(packer)
	}
	createPacker: func (size: IntSize2D, bytesPerPixel: UInt) -> GpuPacker {
		result := this _packerBin find(size, bytesPerPixel)
		if (result == null) {
			result = GpuPacker new(size, bytesPerPixel, this)
		}
		result
	}
	createEglRgba: func (size: IntSize2D) -> EglRgba {
		EglRgba new(this _backend _eglDisplay, size)
	}
}

AndroidContextManager: class extends GpuContextManager {
	init: func {
		setShaderSources()
		super(3)
	}
	_createContext: func -> GpuContext {
		AndroidContext new()
	}
}