Extension { #name : #GtCoderToolbarElement }

{ #category : #'*GToolkit4Git' }
GtCoderToolbarElement >> gitButton [
	<gtCoderAction>
	
	toolbarElement addItem: self newGitButton
]

{ #category : #'*GToolkit4Git' }
GtCoderToolbarElement >> newGitButton [

	^ BrButton new
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
