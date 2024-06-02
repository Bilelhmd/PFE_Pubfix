class DemandeViewModel {
// ValidateSoumettreForm(String description, String cible, String adresse, String service,      String photo, BuildContext context)

  /* ValidateSoumettreForm(String description, String cible, String adresse,
      String service, String photo, BuildContext context) async {
    if (description.isNotEmpty &&
        adresse.isNotEmpty &&
        cible.isNotEmpty &&
        service.isNotEmpty &&
        photo.isNotEmpty) {
      //signup

      await saveDemandeDataToFirestore(
          description, adresse, cible, service, photo);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard()));

      commonVM.showSnackBar("Demande soumise avec succès", context);
    } else {
      commonVM.showSnackBar("Veuillez remplir tous les champs", context);
      return;
    }
  }

// Ajouter de nouveaux contacts à Firestore
  saveDemandeDataToFirestore(
      description, adresse, cible, service, photo) async {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user!.uid)
        .collection("Demande")
        .add({
      //  "uid": currentFirebaseUser.uid,
      "Service": service,
      "Description": description,
      "Adresse": adresse,
      "Cible": cible,
      "Photo": photo,
      "User": user.displayName,
      "Phone": user.phoneNumber,
    });
/*
    await sharefPrefrences!.setString("uid", currentFirebaseUser.uid);
    await sharefPrefrences!.setString("email", email);
    await sharefPrefrences!.setString("name", name);
    await sharefPrefrences!.setString("phone", phone);
    await sharefPrefrences!.setString("password", password);*/
  }*/
}
