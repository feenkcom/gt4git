Class {
	#name : #BrFileBrowserSrcSelector,
	#superclass : #BrVerticalPane,
	#instVars : [
		'brFileBrowserFlderAdder',
		'selectButton',
		'selectedFolderLabel',
		'onSrcFolderSelected'
	],
	#category : #GToolkit4Git
}

{ #category : #accessing }
BrFileBrowserSrcSelector >> createSelectButton [
	|container|
	container := BrHorizontalPane new.
	container hMatchParent; vFitContent.
	container alignCenterRight.
	container padding: (BlInsets right: 10).
	selectedFolderLabel := BrLabel new.
	selectedFolderLabel text:''.
	selectedFolderLabel look: (BrGlamorousLabelLook new glamorousRegularFontAndSize foreground: Color gray).
	selectedFolderLabel padding: (BlInsets right: 20).
	selectButton := BrButton new
				label: 'Select';
				disable;
				look: (BrGlamorousButtonRectangularLook new + BrGlamorousButtonLabelLook new+ BrGlamorousButtonExteriorLook new).
	selectButton action: [
		onSrcFolderSelected ifNotNil: [
			onSrcFolderSelected value: (selectedFolderLabel text asString asFileReference)
		].
	].
	container addChild: selectedFolderLabel.
	container addChild: selectButton.
	^ container
]

{ #category : #accessing }
BrFileBrowserSrcSelector >> folder: aFolder [
	brFileBrowserFlderAdder folder: aFolder
]

{ #category : #accessing }
BrFileBrowserSrcSelector >> initialize [
	super initialize.
	self matchParent.
	brFileBrowserFlderAdder := BrFileBrowserFolderAdder new.
	brFileBrowserFlderAdder onFolderSelectionChanged: [:folder |
		selectButton enable.
		selectedFolderLabel text: folder pathString].
	self addChild: brFileBrowserFlderAdder.
	self addChild: self createSelectButton.
]

{ #category : #accessing }
BrFileBrowserSrcSelector >> onSrcFolderSelected: aBloc [
	onSrcFolderSelected := aBloc
]
