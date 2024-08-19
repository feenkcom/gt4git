Class {
	#name : #GtGitNewBranchForm,
	#superclass : #Object,
	#instVars : [
		'dropdown',
		'branch',
		'repository'
	],
	#category : #'GToolkit4Git-Inspector Integration - Actions'
}

{ #category : #accessing }
GtGitNewBranchForm >> asElement [
	^ (self asGtMagritteViewModel
		onElementCreated: [ :aFrame | 
			BlFocusFinder new
				direction: BlFocusSearchDirectionForward new;
				root: aFrame;
				referenceElement: nil;
				nextFocusDo: #requestFocus ifNone: [  ] ]) asElement
		padding: ((BlInsets all: 10) withRight: 5)
]

{ #category : #accessing }
GtGitNewBranchForm >> branch [
	^ branch
]

{ #category : #accessing }
GtGitNewBranchForm >> branch: anObject [
	branch := anObject
]

{ #category : #accessing }
GtGitNewBranchForm >> branchDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'New Branch Name';
		priority: 1;
		accessor: #branch;
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousCodeFontAndSmallSize ]
]

{ #category : #accessing }
GtGitNewBranchForm >> dropdown [
	^ dropdown
]

{ #category : #accessing }
GtGitNewBranchForm >> dropdown: anObject [
	dropdown := anObject
]

{ #category : #accessing }
GtGitNewBranchForm >> initialize [
	super initialize.
	branch := ''
]

{ #category : #accessing }
GtGitNewBranchForm >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		onSuccessCallback: [ [ | imageCommit |
			imageCommit := repository workingCopy referenceCommit.
			repository createBranch: self branch inCommit: imageCommit.
			Iceberg announcer announce: (IceRepositoryModified for: repository).
			dropdown
				ifNotNil: [ :aDropdown | 
					aDropdown
						enqueueTask: (BlTaskAction new action: [ aDropdown dispatchEvent: BrDropdownHideWish new ]) ] ]
				on: Error
				do: #debug ];
		beEnabledOnValidOverallStatus
]

{ #category : #accessing }
GtGitNewBranchForm >> repository: aRepository [
	repository := aRepository 
]
