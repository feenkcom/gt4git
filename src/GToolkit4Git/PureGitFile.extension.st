Extension { #name : #PureGitFile }

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtAnalyzeActionFor: composite [
	<gtAction>
	^ composite button
		label: 'Analyze';
		priority: 20;
		tooltip: 'Analyze history over time';
		action: [ :aButton | aButton phlow spawnObject: self analyze ]
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtContentsFor: composite [
	<gtView>
	| text |
	[ text := self fileReference contents ] 
		on: ZnCharacterEncodingError 
		do: [ ^ composite empty ].
	^ composite textEditor
		title: 'Contents';
		priority: 30;
		tooltip: 'Current contents in work tree on file system';
		glamorousCodeFontAndSize;
		text: [ text ]
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtLogFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'History';
		priority: 40;
		tooltip: 'Commit log restricted to ' , self path;
		items: [ self log ];
		column: 'Commit' text: [ :commit | commit shortCommitId ] weight: 0.5;
		column: 'Timestamp' text: [ :commit | timestampFormat format: commit timestamp ] weight: 0.5;
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ] weight: 2
]
