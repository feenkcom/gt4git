Extension { #name : #PureGitDiffTool }

{ #category : #'*GToolkit4Git' }
PureGitDiffTool >> asRopedText [
	| textStream |
	textStream := BlTextStream new.
	textStream glamorousCodeFont.
	({ self diffSummary } , self diffLines)  do: [ :line |
		self renderDiff: line on: textStream next ].
	^ textStream contents
]

{ #category : #'*GToolkit4Git' }
PureGitDiffTool >> gtDetails [
	^ super gtDetails , {
		'diff args' . self diffArgs }
]

{ #category : #'*GToolkit4Git' }
PureGitDiffTool >> renderDiff: line on: textStream [
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
