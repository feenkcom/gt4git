Extension { #name : #UnifiedDiffChangeChunk }

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewDiffLinesFor: composite [
	<gtView>
	diffLines ifNil: [ ^ composite empty ].
	^ composite columnedList
		title: 'DiffLines';
		priority:  25;
		items: [ self diffLinesWithPositions ];
		column: 'old #' 
			text: [ :item | item first ifNil: [ '' ] ]
			weight: 0.25;
		column: 'new #' 
			text: [ :item | item second ifNil: [ '' ] ]
			weight: 0.25;
		column: 'line' 
			text: [ :item | | text |
				text := item third asRopedText glamorousCodeFont.
				text first = $-
					ifTrue: [ text highlight: BrGlamorousColors removeLineColor ].
				text first = $+
					ifTrue: [ text highlight: BrGlamorousColors insertLineColor ].
				text ]
			weight: 3
]

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewNewContentsFor: composite [
	<gtView>
	diffLines ifNil: [ ^ composite empty ].
	^ composite columnedList
		title: 'NewContents';
		priority:  35;
		items: [ self newContentsLines ];
		column: 'old #' 
			text: [ :item :position | newStart + position - 1 ]
			weight: 0.25;
		column: 'line' 
			text: [ :item | | text |
				text := item asRopedText glamorousCodeFont.
				text first = $-
					ifTrue: [ text highlight: BrGlamorousColors removeLineColor ].
				text first = $+
					ifTrue: [ text highlight: BrGlamorousColors insertLineColor ].
				text ]
			weight: 3
]

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewOldContentsFor: composite [
	<gtView>
	diffLines ifNil: [ ^ composite empty ].
	^ composite columnedList
		title: 'OldContents';
		priority:  30;
		items: [ self oldContentsLines ];
		column: 'old #' 
			text: [ :item :position | oldStart + position - 1 ]
			weight: 0.25;
		column: 'line' 
			text: [ :item | | text |
				text := item asRopedText glamorousCodeFont.
				text first = $-
					ifTrue: [ text highlight: BrGlamorousColors removeLineColor ].
				text first = $+
					ifTrue: [ text highlight: BrGlamorousColors insertLineColor ].
				text ]
			weight: 3
]

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewRangeFor: composite [
	<gtView>
	^ composite text
		title: 'Range';
		priority:  20;
		text: [ self range ]
]
