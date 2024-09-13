Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> changes [
	| numstat filesChangedCount additionsCount deletionsCount diff textStream |
	textStream := BlTextStream new.
	textStream glamorousCodeFont.

	numstat := self repository diff: { '--numstat' . self id , '^' . self id }.

	numstat := numstat collect: [ :each | | elements |
		elements := Character tab split: each.
		{ Integer readFrom: elements first ifFail: [ 0 ] . Integer readFrom: elements second ifFail: [ 0 ] } ].
	filesChangedCount := numstat size.
	additionsCount := numstat sum: #first.
	deletionsCount := numstat sum: #second.
	numstat := '{1} with {2} and {3.' format: {
		filesChangedCount pluralize: 'changed file'. 
		additionsCount pluralize: 'addition'.
		deletionsCount pluralize: 'deletion' }.

	textStream next putAll: numstat; cr.

	diff := self repository diff: { self id , '^' . self id }.

	diff do: [ :line | | next |
		next := textStream next.
		(line beginsWith: 'diff --git')
			ifTrue: [ next cr; highlight: BrGlamorousColors defaultHeaderBackgroundColor ].
		line first = $@
			ifTrue: [ next highlight: BrGlamorousColors selectedListItemColor ].
		line first = $+
			ifTrue: [ next highlight: BrGlamorousColors insertLineColor ].
		line first = $-
			ifTrue: [ next highlight: BrGlamorousColors removeLineColor ].
		((line beginsWith: '---') or: [ line beginsWith: '+++' ])
			ifFalse: [ next putAll: line; cr ] ].
	
	^ textStream contents
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Changes';
		priority: 24;
		text: [ self changes ]
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
