Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> changesToParentAsRopedText [
	^ self repository diffTool
		diffArgs: self changesToParentDiffArgs;
		asRopedText
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
	^ super gtDetails , {
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
		{ 'timestamp' . self timestamp }.
		{ 'comment' 
			. self comment firstLineWithEllipsis
			. self comment }.
		{ 'URL' . self gitHubURL ifNil: [ '' ] }.
	}
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
PureGitCommit >> gtPackagesFor: composite [
	<gtView>
	self repository isCodeRepository ifFalse: [ ^ composite empty ].
	^ composite list
		title: 'Packages';
		priority: 50;
		tooltip: 'Source code packages at time of commit';
		items: [ (self fileSystem / self repository srcDirectory basename) 
					directories collect: #basename ];
		itemText: #yourself;
		send: [ :package | | reader |
			reader := TonelReader 
						on: self fileSystem / self repository srcDirectory basename 
						fileName: package.
			reader version changes ]
]
