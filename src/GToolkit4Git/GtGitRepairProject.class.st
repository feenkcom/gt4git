Class {
	#name : #GtGitRepairProject,
	#superclass : #GtGitRepairAction,
	#category : #'GToolkit4Git-Inspector Integration - Actions'
}

{ #category : #accessing }
GtGitRepairProject class >> iceTipClass [
	^ IceTipRepairProject
]

{ #category : #accessing }
GtGitRepairProject >> help [
	^ self class iceTipClass help , '

Add a new source folder (e.g., called "src"), select it, and click on OK to add the missing project metadata.'
	
]

{ #category : #accessing }
GtGitRepairProject >> repairStencil [

	| container srcSelector |
	container := BrVerticalPane new.
	container matchParent.
	container padding: (BlInsets all: 10).
	srcSelector := BrFileSelector new folder:
		               repository repositoryDirectory.
	container addChild: (BrEditor new
			 aptitude: BrGlamorousRegularEditorAptitude new;
			 vFitContent;
			 text: self help).
	container addChild: srcSelector.
	srcSelector okAction: [ :srcFolder | 
		| model |
		model := IceBasicProject onRepository: repository.
		model sourceDirectory:
			(srcFolder relativeTo: repository repositoryDirectory) pathString.
		model fileFormat: IceLibgitTonelWriter.
		self assert:
			model repositoryProperties fileFormat = IceLibgitTonelWriter.
		"Set the project in the repository"
		repository workingCopy project: model.
		Iceberg announcer announce: (IceRepositoryModified for: repository).
		dropdown enqueueTask: (BlTaskAction new action: [ 
				 dropdown dispatchEvent: (BrDropdownHideWish new anchor: dropdown).
				 dropdown phlow fireUpdateWish ]) ].
	^ container
]
