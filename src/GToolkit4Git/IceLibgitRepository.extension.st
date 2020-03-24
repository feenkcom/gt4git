Extension { #name : #IceLibgitRepository }

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtActionFetchFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Fetch';
		action: [ 
			(IceTipRepositoryModel on: self) fetch ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtLocalBranchesFor: aView [
	self isMissing ifTrue: [ ^ aView ].
	^ super gtLocalBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRemoteBranchesFor: aView [
	self isMissing ifTrue: [ ^ aView ].
	^ super gtRemoteBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView ].
	^ (self repositoryDirectory gtItemsFor: aView)
		title: 'Repository directory' translated;
		priority: 35
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtTagsFor: aView [
	self isMissing ifTrue: [ ^ aView ].
	^ super gtTagsFor: aView
]
