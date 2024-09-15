Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> changes [
	| diff textStream |
	textStream := BlTextStream new.
	textStream glamorousCodeFont.
	textStream next putAll: self changesSummary; cr.
	diff := self repository diff: { '--no-prefix' . self id , '^' . self id }.
	diff do: [ :line |
		self renderDiff: line on: textStream next ].
	^ textStream contents
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> changesSummary [
	| numstat filesChangedCount additionsCount deletionsCount |
	numstat := self repository diff: { '--numstat' . self id , '^' . self id }.
	numstat := numstat collect: [ :each | | elements |
		elements := Character tab split: each.
		Array 
			with: (Integer readFrom: elements first ifFail: [ 0 ])
			with: (Integer readFrom: elements second ifFail: [ 0 ]) ].
	filesChangedCount := numstat size.
	additionsCount := numstat sum: #first.
	deletionsCount := numstat sum: #second.
	^ '{1} with {2} and {3.' format: {
		filesChangedCount pluralize: 'changed file'. 
		additionsCount pluralize: 'addition'.
		deletionsCount pluralize: 'deletion' }
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

{ #category : #'*GToolkit4Git' }
PureGitCommit >> renderDiff: line on: textStream [
	| lineOut |
	lineOut := line.
	(line beginsWith: 'diff --git')
		ifTrue: [ 
			textStream cr; highlight: BrGlamorousColors defaultHeaderBackgroundColor.
			^ textStream putAll: ($ join: ($ split: line) allButLast); cr ].
	(#('---' '+++' 'index') anySatisfy: [ :prefix | line beginsWith: prefix ])
		ifTrue: [ ^ self].
	(line beginsWith: 'new file')
		ifTrue: [ ^ textStream putAll: 'new file'; cr ]. 
	(line beginsWith: 'deleted file')
		ifTrue: [ ^ textStream putAll: 'deleted file'; cr ]. 
	line first = $@
		ifTrue: [ textStream highlight: BrGlamorousColors selectedListItemColor ].
	line first = $+
		ifTrue: [ textStream highlight: BrGlamorousColors insertLineColor ].
	line first = $-
		ifTrue: [ textStream highlight: BrGlamorousColors removeLineColor ].
	textStream putAll: line; cr
]
