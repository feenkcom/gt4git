Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> changesRendered [
	| textStream |
	textStream := BlTextStream new.
	textStream glamorousCodeFont.
	self changes do: [ :line |
		self renderDiff: line on: textStream next ].
	^ textStream contents
]

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Changes';
		priority: 24;
		text: [ self changesRendered ]
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
	| lineOut firstNonSeparator |
	lineOut := line.
	(line beginsWith: 'diff --git')
		ifTrue: [ | elements |
			textStream highlight: BrGlamorousColors defaultHeaderBackgroundColor.
			elements := $ split: line.
			textStream cr.
			elements third = elements fourth
				ifTrue: [ textStream putAll: ($ join: elements allButLast) ]
				ifFalse: [ textStream putAll: line ].
			^ textStream cr ].
	(#('---' '+++' 'index') anySatisfy: [ :prefix | line beginsWith: prefix ])
		ifTrue: [ ^ self ].
	(line beginsWith: 'new file')
		ifTrue: [ ^ textStream putAll: 'new file'; cr ]. 
	(line beginsWith: 'deleted file')
		ifTrue: [ ^ textStream putAll: 'deleted file'; cr ].
	firstNonSeparator := line detect: [ :char | char isSeparator not ] ifNone: [ nil ].
	firstNonSeparator = $@
		ifTrue: [ textStream highlight: BrGlamorousColors selectedListItemColor ].
	firstNonSeparator = $+
		ifTrue: [ textStream highlight: BrGlamorousColors insertLineColor ].
	firstNonSeparator = $-
		ifTrue: [ textStream highlight: BrGlamorousColors removeLineColor ].
	textStream putAll: line; cr
]
