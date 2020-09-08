Class {
	#name : #GtGitRepairProject,
	#superclass : #GtGitRepairAction,
	#category : #'GToolkit4Git-Actions'
}

{ #category : #accessing }
GtGitRepairProject class >> iceTipClass [
	^ IceTipRepairProject
]

{ #category : #accessing }
GtGitRepairProject >> repairStencil [
	|container srcSelector |
	container := BrVerticalPane new.
	container matchParent.
	srcSelector := BrFileBrowserSrcSelector new folder: repository repositoryDirectory.
	container addChild:(BrEditor new
		look: BrGlamorousRegularEditorLook new;
		vFitContent;
		text: self class iceTipClass help).
	container addChild: srcSelector.
	srcSelector onSrcFolderSelected: [:srcFolder | ].
  ^ container
]
