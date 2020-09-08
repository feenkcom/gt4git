Class {
	#name : #BrFileBrowserFolderAdder,
	#superclass : #BrFileBrowser,
	#instVars : [
		'brFileBrowser',
		'folderCreator'
	],
	#category : #GToolkit4Git
}

{ #category : #accessing }
BrFileBrowserFolderAdder >> initialize [
	super initialize.
]

{ #category : #accessing }
BrFileBrowserFolderAdder >> onFolderSelectionChanged: aBloc [
	table when: BrSelectionChanged
			do: [:selectionEvent |
				selectionEvent indices size = 1 ifTrue: [
					aBloc value: (table items at: (selectionEvent indices first))] ]
]

{ #category : #accessing }
BrFileBrowserFolderAdder >> updateDisplay [
	super updateDisplay.
	folderCreator := BrFolderCreateWidget new
		folder: folder;
		onFolderCreated: [self updateDisplay];
		defaultFolderName: 'src'.
	breadcrumb addItem: (folderCreator).
]
