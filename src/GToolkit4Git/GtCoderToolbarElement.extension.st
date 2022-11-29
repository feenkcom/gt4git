Extension { #name : #GtCoderToolbarElement }

{ #category : #'*GToolkit4Git' }
GtCoderToolbarElement >> gitButtonFor: anAction [

	<gtAction>
	^ anAction button
		tooltip: 'Go to repository';
		priority: 4;
		  icon: BrGlamorousVectorIcons branching;
		  action: [ :aDropdown | 
			  | repository |
			  self halt.
			  repository := self repository.
			  repository
				  ifNil: [ 
					  aDropdown phlow spawnTool: (GtPhlowValuableTool new valuable: [ 
									   GtGitAddToRepositoryElement new package:
											   self navigationModel selectedPackage ]) ]
				  ifNotNil: [ 
					  aDropdown phlow spawnTool: (GtPhlowValuableTool new valuable: [ 
									   GtGitElement new repository: self repository ]) ] ]
]
