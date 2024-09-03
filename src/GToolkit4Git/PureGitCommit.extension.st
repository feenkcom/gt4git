Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtDetails [
	^ super gtDetails , {
		{ 'commit' . self id  }.
		{ 'tree' 
			. self treeId
			. self tree }.
		{ 'parents'
			. self parentIds asCommaString
			. self parents }.
		{ 'author' . self author }.
		{ 'timestamp' . self timestamp }.
		{ 'comment' . self comment }
	}
]
