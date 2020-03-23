Class {
	#name : #Gt4Git,
	#superclass : #Object,
	#category : #GToolkit4Git
}

{ #category : #accessing }
Gt4Git >> gtRepositoriesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Repositories' translated;
		priority: 50;
		items: [ self repositories];
		column: 'Repository' translated format: [ :each | 
		|description|
		description := each name asRopedText.
	
		each isModified ifTrue: [ 
			description := ('*', description asString) asRopedText.
			description attributes: {BlTextForegroundAttribute paint: (Color r: 0 g: 0.5 b: 0)} ].
		description ] width: 200;
		column: 'Branch' translated format: [ :each | each headDescription ] width: 200;
		column: 'Status' translated format: [ :each | (IceTipRepositoryModel on: each) status ] width: 200.
]

{ #category : #accessing }
Gt4Git >> repositories [
	|repos|
	repos := IceRepository registry.
	repos := repos sort: [:a :b | 
	|aM bM result|
	aM := (IceTipRepositoryModel on: a).
	bM := (IceTipRepositoryModel on: b).
	(aM isModified and:[ bM isModified not]) ifTrue: [result := true]. 
	(bM isModified and:[ aM isModified not]) ifTrue: [result := false].
	
	(result ifNil: [result := a name translateToLowercase < b name translateToLowercase]).
	result].
	^ repos
]
