Extension { #name : #Behavior }

{ #category : #'*GToolkit4Git' }
Behavior >> gtGitButtonFor: anAction [
	<gtClassAction>
	^ anAction button
		tooltip: 'Go to repository';
		priority: 4;
		icon: BrGlamorousVectorIcons branching;
		id: GtCoderGitButtonId;
		action: [ :aButton | 
			| coder repository |
			coder := aButton phlow firstParentCoder.
			coder navigationModel hasSelectedPackageOrClass
				ifTrue: [ repository := coder repository.
					repository
						ifNil: [ aButton phlow
								spawnTool: (GtPhlowExplicitTool new
										stencil: [ GtGitAddToRepositoryElement new package: coder navigationModel selectedPackage ]) ]
						ifNotNil: [ aButton phlow
								spawnTool: (GtGitPhlowTool new repository: repository) ] ] ]
]
