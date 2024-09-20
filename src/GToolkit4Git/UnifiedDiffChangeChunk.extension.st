Extension { #name : #UnifiedDiffChangeChunk }

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewDiffLinesFor: composite [
	<gtView>
	diffLines ifNil: [ ^ composite empty ].
	^ composite list
		title: 'DiffLines';
		priority:  25;
		items: [ diffLines ]
]

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewNewContentsFor: composite [
	<gtView>
	diffLines ifNil: [ ^ composite empty ].
	^ composite textEditor
		title: 'NewContents';
		priority:  30;
		glamorousCodeFontAndSize;
		text: [ self newContents ]
]

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewOldContentsFor: composite [
	<gtView>
	diffLines ifNil: [ ^ composite empty ].
	^ composite textEditor
		title: 'OldContents';
		priority:  30;
		glamorousCodeFontAndSize;
		text: [ self oldContents ]
]

{ #category : #'*GToolkit4Git' }
UnifiedDiffChangeChunk >> gtViewRangeFor: composite [
	<gtView>
	^ composite text
		title: 'Range';
		priority:  20;
		text: [ self range ]
]
