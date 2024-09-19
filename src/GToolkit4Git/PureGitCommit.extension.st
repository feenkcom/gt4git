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
		text: [ self changesToParentAsRopedText ]
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
			. self comment }
	}
]
