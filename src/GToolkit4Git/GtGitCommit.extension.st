Extension { #name : #GtGitCommit }

{ #category : #'*GToolkit4Git' }
GtGitCommit >> gtVerificationFor: aView [
	<gtView>
	(PureGitUrl with: self repository origin url) gitHubWebUrl
		ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Verification';
		priority: 60;
		object: [ (PureGitRepository on: self repository location) queries
				resolveCommit: self id ];
		view: #gtVerificationFor:
]
