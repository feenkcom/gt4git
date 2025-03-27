Extension { #name : #AbstractFileReference }

{ #category : #'*GToolkit4Git' }
AbstractFileReference >> filename [
	^self basename
]

{ #category : #'*GToolkit4Git' }
AbstractFileReference >> gtActionGitRepositoryFor: anAction [
	<gtAction>

	(self path isNetworkPath not and:
	[ (self exists and: [ self isDirectory and: [ (self / '.git') exists ] ]) ])
		ifFalse: [ ^ anAction noAction ].

	^ anAction button
		icon: BrGlamorousVectorIcons branching;
		tooltip: 'Open git repository';
		action: [ :element | element phlow spawnObject: (PureGitRepository on: self) ]
]

{ #category : #'*GToolkit4Git' }
AbstractFileReference >> name [
	^self basename
]
