Extension { #name : #PureGitTrackedFileLineVersion }

{ #category : #'*GToolkit4Git' }
PureGitTrackedFileLineVersion >> gtContentsFor: composite [
	<gtView>
	^ composite explicit
		title: 'Contents';
		priority: 30;
		stencil: [ | contents lineRange editor element |
			contents := self commit contents.
			lineRange := contents intervalOfLine: self lineNumber.
			editor := BrEditor new
				aptitude: BrGlamorousCodeEditorAptitude new;
				text: contents;
				beReadOnlyWithoutSelection.
			element := editor asElement.
			element editor
				selectNone;
				select: lineRange first - 1 to: lineRange last.
			element
				scrollToPosition: (self lineNumber - 3 max: 1);
				margin: (BlInsets all: 5).
			element ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFileLineVersion >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'path' . self path }.
			{ 'extended commit' . self extendedCommit shortId . self extendedCommit }.
			{ 'commit' . self commit shortCommitId . self commit }.
			{ 'line number' . self lineNumber }.
			{ 'line contents' . self lineContents }.
			{ 'tracked file version' . self file }.
			{ 'tracked line' . self line }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFileLineVersion >> gtLineOwnershipEvolutionFor: composite [
	<gtView>
	^ composite explicit
		title: 'Kumpel';
		priority: 40;
		tooltip: 'Show selected line history over time';
		stencil: [ | container |
			container := BlElement new.
			self trackedFile uniqueTrackedLines
				do: [ :trackedLine | 
					| element color |
					element := trackedLine asKumpelGraphElement.
					color := trackedLine = self line
						ifTrue: [ self trackedFile contrastColorForAuthor: (self trackedFile authorOfTrackedLine: trackedLine) ]
						ifFalse: [ self trackedFile colorForAuthor: (self trackedFile authorOfTrackedLine: trackedLine) ].
					element
						background: color;
						border: color.
					container addChild: element ].
			container
				size: ((self trackedFile versions size *  (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin))
							- PureGitTrackedLine versionMargin)
						@ (PureGitTrackedLine lineHeight * self trackedFile maxLinesCount).
			container
				addChild: (BlElement new
						background: (Color black alpha: 0.3);
						zIndex: 100;
						size: PureGitTrackedLine versionWidth @ (PureGitTrackedLine lineHeight * self file lines size);
						relocate: ((self file versionNumber - 1)
											* (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin))
										@ 0).
			container beInSeparateCompositionLayer asCanvassableElement
				margin: (BlInsets all: 10) ]
]
