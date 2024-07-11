Extension { #name : #IceGitRemote }

{ #category : #'*GToolkit4Git' }
IceGitRemote >> gtBranchesFor: aView [
	<gtView>
	
	self localRepository ifNil: [ ^ aView empty ].
	
	^ aView list
		title: 'Branches';
		items: [  self branches ]
]
