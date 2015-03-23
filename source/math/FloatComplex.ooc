//
// Copyright (c) 2011-2012 Anders Frisk
// Copyright (c) 2012-2015 Simon Mika <simon@mika.se>
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

import math

FloatComplex: cover {
	real, imaginary: Float
	init: func@ (=real, =imaginary)
	conjugate ::= FloatComplex new(this real, - this imaginary)
	absoluteValue ::= (this real pow(2) + this imaginary pow(2)) sqrt()
	operator + (other: This) -> This {This new(this real + other real, this imaginary + other imaginary)}
	operator - (other: This) -> This {This new(this real - other real, this imaginary - other imaginary)}
	operator - -> This {This new(-this real, -this imaginary)}
	operator * (other: This) -> This {This new(this real * other real - this imaginary * other imaginary, this real * other imaginary + this imaginary * other real)}
	operator * (other: Float) -> This {This new(other * this real, other * this imaginary)}
	
}
