Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtCommentFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Comment';
		priority: 25;
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
