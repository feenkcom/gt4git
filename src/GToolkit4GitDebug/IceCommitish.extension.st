Extension { #name : #IceCommitish }

{ #category : #'*GToolkit4GitDebug' }
IceCommitish >> snapshotForPackage: anIceSavedPackage [

	| aSignal |
	aSignal := GtIceSnapshotForPackageSignal new
		savedPackage: anIceSavedPackage;
		emit.

	^ [ | savedVersion mcVersion aSnapshot |
		savedVersion := self versionFor: anIceSavedPackage.
		aSignal savedVersion: savedVersion.
		mcVersion := self mcVersionFor: savedVersion.
		aSignal mcVersion: mcVersion.
		aSnapshot := mcVersion snapshot.
		aSignal snapshot: aSnapshot.
		aSnapshot ]
		on: IceVersionDoesNotExist 
		do: [ 
			aSignal versionDoesNotExist.
			MCSnapshot empty ]
]
