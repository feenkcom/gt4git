Extension { #name : #PureGitFileStatus }

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
		{ 'original path' . self originalPath ifNil: [ '' ] . self originalPath }.
		{ 'status in index' . self statusInIndex }.
		{ 'status in work tree' . self statusInWorkTree }
	}
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtStagedChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Staged';
		priority: 30;
		tooltip: 'Changes added to index for next commit';
		text: [ self stagedChangesAsRopedText ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtUnstagedChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Unstaged';
		priority: 35;
		tooltip: 'Changes made after file was added to index';
		text: [ self unstagedChangesAsRopedText ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> stagedChangesAsRopedText [
	^ self repository diffTool
		diffArgs: { '--staged' . self path };
		asRopedText
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> unstagedChangesAsRopedText [
	^ self repository diffTool
		diffArgs: { self path };
		asRopedText
]
