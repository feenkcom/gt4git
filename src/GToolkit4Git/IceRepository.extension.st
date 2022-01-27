Extension { #name : #IceRepository }

{ #category : #'*GToolkit4Git' }
IceRepository >> gtLocalBranchesFor: aView [
	<gtView>
	^ aView list
		title: 'Branches' translated;
		priority: 20;
		items: [ self localBranches ];
		itemText: #name
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtPackagesFor: aView [
	<gtView>
	^ self workingCopy 
		ifNil: [ aView ]
		ifNotNil: [ self workingCopy gtPackagesFor: aView ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtRemoteBranchesFor: aView [
	<gtView>
	^ aView list
		title: 'Remotes' translated;
		priority: 24;
		items: [ self remoteTrackedBranches ];
		itemText: #name
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtTagsFor: aView [
	<gtView>
	^ aView list
		title: 'Tags' translated;
		priority: 30;
		items: [ self tags ];
		itemText:
				[ :anIceTag | anIceTag name , ' [' , (anIceTag commit id first: 7) , ']' ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtViewDiffToReferenceCommitFor: aView [
	"<gtView>"
	^ self workingCopy 
		ifNil: [ aView ]
		ifNotNil: [ self workingCopy gtViewDiffToReferenceCommitFor: aView ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> packages [
	^ self workingCopy packages
]
