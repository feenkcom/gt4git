Extension { #name : #GtCoderToolbarElement }

{ #category : #'*GToolkit4Git' }
GtCoderToolbarElement >> gitButtonFor: anAction [

	<gtAction>
	^ anAction button
		tooltip: 'Go to repository';
		priority: 4;
		  icon: BrGlamorousVectorIcons branching;
		  action: [ :_ | 
			  | repository |
			  repository := self repository.
			  repository
				  ifNil: [ 
					  self phlow spawnTool: (GtPhlowValuableTool new valuable: [ 
									   GtGitAddToRepositoryElement new package:
											   self navigationModel selectedPackage ]) ]
				  ifNotNil: [ 
					  self phlow spawnTool: (GtPhlowValuableTool new valuable: [ 
									   GtGitElement new repository: self repository ]) ] ]
]

{ #category : #'*GToolkit4Git' }
GtCoderToolbarElement >> newGitButton [

	^ self createActionButton
		  aptitude: BrGlamorousButtonWithIconAptitude;
		  label: 'Go to repository';
		  icon: BrGlamorousVectorIcons branching;
		  action: [ :_ | 
			  | repository |
			  repository := self repository.
			  repository
				  ifNil: [ 
					  self phlow spawnTool: (GtPhlowValuableTool new valuable: [ 
									   GtGitAddToRepositoryElement new package:
											   self navigationModel selectedPackage ]) ]
				  ifNotNil: [ 
					  self phlow spawnTool: (GtPhlowValuableTool new valuable: [ 
									   GtGitElement new repository: self repository ]) ] ]
]
