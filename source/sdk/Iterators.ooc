Iterable: abstract class <T> {
	iterator: abstract func -> Iterator<T>
	reduce: func (f: Func (T, T) -> T) -> T {
		iter := iterator()
		acc := f(iter next(), iter next())
		while (iter hasNext?())
			acc = f(acc, iter next())
		acc
	}
	each: func (f: Func (T)) {
		for (elem in this)
			f(elem)
	}
	// Return false to break
	eachUntil: func (f: Func (T) -> Bool) {
		for (elem in this)
			if (!f(elem)) break
	}
	each: func ~withIndex (f: Func (T, Int)) {
		index := 0
		for (elem in this) {
			f(elem, index)
			index += 1
		}
	}
}

BackIterable: abstract class <T> extends Iterable<T> {
	iterator: abstract func -> BackIterator<T>
	/** Returns an iterator at the back or end of the Iterable. */
	backIterator: func -> BackIterator<T> {
		iter := iterator()
		while (iter hasNext?())
			iter next()
		return iter
	}
	forward: func -> BackIterator<T> { iterator() }
	backward: func -> BackIterator<T> { backIterator() reversed() }
}

Iterator: abstract class <T> extends Iterable<T> {
	hasNext?: abstract func -> Bool
	next: abstract func -> T
	remove: abstract func -> Bool
	iterator: override func -> This<T> { this }
	map: func<T, S> (S: Class, function: Func(T) -> S) -> This<S> {
		_MappingIterator<T, S> new(this, function)
	}
}

BackIterator: abstract class <T> extends Iterator<T> {
	hasPrev?: abstract func -> Bool
	prev: abstract func -> T
	iterator: func -> This<T> { this }
	reversed: func -> ReverseIterator<T> {
		iter := ReverseIterator<T> new()
		iter iterator = this
		return iter
	}
}

ReverseIterator: class <T> extends BackIterator<T> {
	iterator: BackIterator<T> = null
	init: func
	hasNext?: override func -> Bool { iterator hasPrev?() }
	next: override func -> T { iterator prev() }
	hasPrev?: override func -> Bool { iterator hasNext?() }
	prev: override func -> T { iterator next() }
	remove: override func -> Bool { iterator remove() }
	reversed: func -> BackIterator<T> { iterator }
	iterator: func -> This<T> { this }
}

_MappingIterator: class <T, S> extends Iterator<S> {
	_backend: Iterator<T>
	_mapFunction: Func(T) -> S
	init: func (=_backend, =_mapFunction)
	free: func {
		this _backend free()
		super()
	}
	hasNext?: override func -> Bool {
		this _backend hasNext?()
	}
	next: override func -> S {
		this _mapFunction(this _backend next())
	}
	remove: override func -> Bool {
		this _backend remove()
	}
}