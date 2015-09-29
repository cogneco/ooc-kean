use ooc-base
use ooc-unit

PromiseCollectorTest: class extends Fixture {
	init: func {
		super("PromiseCollector")
		this add("simple (+ operator)", func {
			promise := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise2 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise3 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise4 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promises := promise + promise2 + promise3 + promise4
			expect(promises wait())
			promises free()
		})
		this add("advanced (+= operator)", func {
			promises := PromiseCollector new()

			for (j in 0 .. 5) {
				promises += Promise start(func { for (i in 0 .. 100_000_000) { } } )
			}

			extra := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			extra cancel()
			promises += extra

			others := PromiseCollector new()
			for (j in 0 .. 5) {
				others += Promise start(func { for (i in 0 .. 100_000_000) { } } )
			}
			promises += others

			expect(others wait())
			expect(!promises wait())

			promises free()
		})
		this add("clear old promises", func {
			promise := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise cancel()
			promise2 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promises := promise + promise2
			expect(!promises wait())
			promises clear()
			promises += Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promises += Promise start(func { for (i in 0 .. 100_000_000) { } } )
			expect(promises wait())
			promises clear()
		})
	}
}

PromiseCollectorTest new() run()
