Extension { #name : #IceLibgitRepository }

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> getDeltas [

	^ handle getDeltas collect: [ :delta | 
		  GtGitDelta from: delta in: self ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> getStatus [
	^ handle getStatus
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtLocalBranchesFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtLocalBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRemoteBranchesFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtRemoteBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRepositoryDirectoryFor: aView [

	<gtView>
	| status |
	"status := self getStatus."
	self isMissing ifTrue: [ ^ aView empty ].
	^ (self repositoryDirectory gtItemsFor: aView)
		  title: 'Repository directory' translated;
		  priority: 35;
		  "column: 'Tracked' translated
		  	icon: [ :each |
		  		BrGlamorousIcons accept  ];"
		  column: 'Actions'  translated
		  	stencil: [ :each |
		  	  | relative |
		  	  relative := each relativeTo: self repositoryDirectory.
			BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons add;
				label: 'Add ', relative pathString;
				beTinySize;
				action: [:_ | self index addPath: relative; addToGitIndex]];
		  actionButtonIcon: BrGlamorousIcons go
		  tooltip: 'Open in OS'
		  action: [ WebBrowser openOn: self location fullName ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtTagsFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtTagsFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> isDirty [

	^ handle ifNil: [ false ] ifNotNil: [ handle isDirty ]
]
