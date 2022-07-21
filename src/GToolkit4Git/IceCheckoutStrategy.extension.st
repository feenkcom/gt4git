Extension { #name : #IceCheckoutStrategy }

{ #category : #'*GToolkit4Git' }
IceCheckoutStrategy class >> allGtStrategies [

	^ (self allSubclasses sorted: [ :a :b | a order < b order ])
		  select: [ :e | e canBeUsedFromUI and: [ e isGtStrategy ] ]
		  thenCollect: [ :e | e new ]
]

{ #category : #'*GToolkit4Git' }
IceCheckoutStrategy class >> gtDescription [
	^ self subclassResponsibility
]

{ #category : #'*GToolkit4Git' }
IceCheckoutStrategy >> gtDescription [
	^ self class gtDescription
]

{ #category : #'*GToolkit4Git' }
IceCheckoutStrategy class >> isGtStrategy [
	^ false
]
