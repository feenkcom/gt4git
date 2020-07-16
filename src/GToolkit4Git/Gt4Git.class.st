Class {
	#name : #Gt4Git,
	#superclass : #Object,
	#category : #GToolkit4Git
}

{ #category : #accessing }
Gt4Git >> allRepositoriesGroup [
	^ GtGitRepositoryGroup new repositories: self repositories.
]

{ #category : #accessing }
Gt4Git >> repositories [
	|repos|
	repos := IceRepository registry copyFrom: 1 to: IceRepository registry size.
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
