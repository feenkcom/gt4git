Class {
	#name : #GtGitRepositoryGroup,
	#superclass : #Object,
	#instVars : [
		'repos'
	],
	#category : #GToolkit4Git
}

{ #category : #accessing }
GtGitRepositoryGroup >> gtRepositoriesFor: aView [
	<gtView>
    |result|
    
	result := aView columnedList
		title: 'Repositories' translated;
		priority: 50;
		updateWhen: IceRepositoryModified in: [Iceberg announcer];
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
	^ result
]

{ #category : #accessing }
GtGitRepositoryGroup >> repositories [
	^ repos
]

{ #category : #accessing }
GtGitRepositoryGroup >> repositories: aListOfRepositories [
	repos := aListOfRepositories copyFrom: 1 to: aListOfRepositories size.
]
