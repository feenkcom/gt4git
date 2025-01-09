Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> changesToParentAsRopedText [
	^ self repository diffTool
		diffArgs: self changesToParentDiffArgs;
		asRopedText
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'Commit operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | BrGlamorousSimpleContextMenuContent new items: self gtOperations ]
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Changes';
		priority: 24;
		text: [ self changesToParentAsRopedText ];
		actionButtonIcon: BrGlamorousVectorIcons changes
			tooltip: 'Unified diff' 
			action: [ :aButton | aButton phlow spawnObject: self changesToParent ]
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtCommentFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Comment';
		priority: 28;
		glamorousCodeFontAndSize;
		text: [ self comment ]
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtDetails [
	| details |
	details := super gtDetails , {
		{ 'commit'
			. self shortCommitId 
			. self id  }.
		{ 'tree' 
			. self shortTreeId
			. self tree }.
		{ 'number of parents' . self numberOfParents }.
		{ 'parents'
			. self shortParentIds asCommaString
			. self parents }.
		{ 'author' . self author }.
		{ 'email' . self email }.
		{ 'timestamp' . self timestamp }.
	}.
	self hasDifferentAuthorAndCommitter 
		ifTrue: [
			details := details , {
				{ 'committer' . self committer }.
				{ 'committer email' . self committerEmail }.
				{ 'committer timestamp' . self committerTimestamp }.
		} ].
	details := details , {
		{ 'comment' 
			. self comment firstLineWithEllipsis
			. self comment }.
		{ 'github web url' . self gitHubWebUrl ifNil: [ '' ] }.
	}.
	^ details
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtFileSystemFor: aView [
	<gtView>
	^ aView forward
		title: 'Filesystem';
		priority: 40;
		tooltip: 'Filesystem tree at time of commit';
		object: [ self fileSystem ];
		view: #gtTreeFor:
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtOperations [
	^ Array streamContents: [ :actions | 
		actions nextPut: 'Checkout' -> [ :e | 
			e phlow spawnObject: self checkout.
			e fireEvent: BrDropdownHideWish new ] ]
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtPackagesFor: composite [
	<gtView>
	self repository isCodeRepository ifFalse: [ ^ composite empty ].
	^ composite list
		title: 'Packages';
		priority: 50;
		tooltip: 'Source code packages at time of commit';
		items: [ self packageNames ];
		itemText: #yourself;
		contextItemLabel: 'Snapshot'
			action: [ :element :package | 
				| snapshot |
				BlTaskAction
					enqueueElement: element
					action: [ snapshot := (self readerForPackage: package) snapshot.
						element phlow spawnObject: snapshot ] ];
		contextItemLabel: 'Changes to image'
			action: [ :element :package | 
				| changes |
				BlTaskAction
					enqueueElement: element
					action: [ changes := (self readerForPackage: package) version changes.
						element phlow spawnObject: changes ] ];
		contextItemLabel: 'Changes to parent'
			action: [ :element :package | 
				| commitSnapshot parentSnapshot changes |
				BlTaskAction
					enqueueElement: element
					action: [ commitSnapshot := (self readerForPackage: package) snapshot.
						parentSnapshot := (self parent readerForPackage: package) snapshot.
						changes := commitSnapshot patchRelativeToBase: parentSnapshot.
						element phlow spawnObject: changes ] ];
		send: [ :package | (self readerForPackage: package) snapshot ]
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtVerificationFor: composite [
	<gtView>
	self gitHubWebUrl ifNil: [ ^ composite empty ].
	^ composite columnedList
		title: 'Verification';
		priority: 60;
		items: [ | data |
			data := self gitHubData.
			{
				{ 'verified'
					. ((data atPath: #(commit verification verified)) ifNil: [ false ]) gtColoredText
					. data atPath: #(commit verification verified) }.
				{ 'reason' . data atPath: #(commit verification reason) }.
				{ 'author' . self author }.
				{ 'email' . self email }.
				{ 'timestamp' . self timestamp }.
				{ 'committer' . self committer }.
				{ 'committer email' . self committerEmail }.
				{ 'committer timestamp' . self committerTimestamp }.
				{ 'signature' . (data atPath: #(commit verification signature)) ifNil: [ '' ] }.
				{ 'payload' . (data atPath: #(commit verification payload)) ifNil: [ '' ] }.
				{ 'verified at' . (data atPath: #(commit verification 'verified_at')) ifNil: [ '' ] }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
