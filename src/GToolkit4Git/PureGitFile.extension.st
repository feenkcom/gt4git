Extension { #name : #PureGitFile }

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
