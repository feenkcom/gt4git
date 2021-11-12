Extension { #name : #IceLibgitRepository }

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
	self isMissing ifTrue: [ ^ aView empty ].
	^ (self repositoryDirectory gtItemsFor: aView)
		  title: 'Repository directory' translated;
		  priority: 35;
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
