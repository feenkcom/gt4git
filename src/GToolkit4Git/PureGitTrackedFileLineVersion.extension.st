Extension { #name : #PureGitTrackedFileLineVersion }

{ #category : #'*GToolkit4Git' }
PureGitTrackedFileLineVersion >> gtContentsFor: composite [
	<gtView>
	^ composite explicit
		title: 'Contents';
		priority: 40;
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
				scrollToPosition: self lineNumber;
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
