Extension { #name : #Behavior }

{ #category : #'*GToolkit4Git' }
Behavior >> gtGitButtonFor: anAction [
	<gtClassAction>
	^ anAction button
		tooltip: 'Go to repository';
		priority: 4;
		icon: BrGlamorousVectorIcons branching;
		action: [ :aButton | 
			| coder repository |
			coder := aButton phlow firstParentWithView.
			coder navigationModel hasSelectedPackageOrClass
				ifTrue: [ repository := coder repository.
					repository
						ifNil: [ coder phlow
								spawnTool: (GtPhlowValuableTool new
										valuable: [ GtGitAddToRepositoryElement new package: coder navigationModel selectedPackage ]) ]
						ifNotNil: [ coder phlow
								spawnTool: (GtPhlowValuableTool new valuable: [ GtGitElement new repository: repository ]) ] ] ]
]
