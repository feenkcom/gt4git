Extension { #name : #IceGitRemote }

{ #category : #'*GToolkit4Git' }
IceGitRemote >> gtBranchesFor: aView [
	<gtView>
	
	^ aView list
		title: 'Branches';
		items: [  self branches ]
]
